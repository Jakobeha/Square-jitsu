//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Chunk: ReadonlyChunk, Codable {
    static let widthHeight: Int = 32
    static let numLayers: Int = 4

    static let cgSize: CGSize = CGSize.square(sideLength: CGFloat(widthHeight))
    static let extraDistanceFromEntityToUnload: CGFloat = CGFloat(widthHeight) * 2.5

    private var tiles: ChunkMatrix<TileType> = ChunkMatrix()
    var tileBehaviors: [ChunkTilePos3D:TileBehavior] = [:]
    private var sortedTileBehaviors: [(key: ChunkTilePos3D, value: TileBehavior)] {
        tileBehaviors.sorted { $0.key < $1.key }
    }

    private let _didChangeTile: Publisher<(pos3D: ChunkTilePos3D, oldType: TileType)> = Publisher()
    // Exposed for the world class, which signals events through the chunk for views
    let _didAdjacentTileChange: Publisher<ChunkTilePos> = Publisher()
    var didChangeTile: Observable<(pos3D: ChunkTilePos3D, oldType: TileType)> { Observable(publisher: _didChangeTile) }
    var didAdjacentTileChange: Observable<ChunkTilePos> { Observable(publisher: _didAdjacentTileChange) }

    init() {}

    // region basic tile access and mutation
    subscript(_ pos: ChunkTilePos) -> [TileType] {
        tiles[pos]
    }

    subscript(_ pos3D: ChunkTilePos3D) -> TileType {
        get {
            tiles[pos3D]
        }
        set {
            // Change value
            let oldType = self[pos3D]
            tiles[pos3D] = newValue
            let metadataIsDifferent = oldType.bigType != newValue.bigType

            // Remove metadata if necessary
            if metadataIsDifferent {
                tileBehaviors[pos3D] = nil
            }

            // Place metadata if necessary
            if metadataIsDifferent {
                if let newMetadata = newValue.bigType.newBehavior() {
                    tileBehaviors[pos3D] = newMetadata
                }
            }

            // Notify observers of change
            _didChangeTile.publish((pos3D: pos3D, oldType: oldType))
        }
    }

    func getMetadataAt(pos3D: ChunkTilePos3D) -> TileMetadata? {
        tileBehaviors[pos3D]?.untypedMetadata
    }

    func getNextFreeLayerAt(pos: ChunkTilePos) -> Int? {
        tiles.getNextFreeLayerAt(pos: pos)
    }

    /// - Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    ///   deletes the tile, while "remove" may mean it was unloaded
    func removeTiles(pos: ChunkTilePos) {
        let tilesAtPos = self[pos]

        // Remove metadatas
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            tileBehaviors[pos3D] = nil
        }

        // Remove tiles
        tiles.removeAll(at: pos)

        // Notify observers
        for layer in 0..<Chunk.numLayers {
            let oldType = tilesAtPos[layer]
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            _didChangeTile.publish((pos3D: pos3D, oldType: oldType))
        }
    }

    /// Places the tile at the next free layer at the given position.
    /// If there are no free layers at the position, places at the last layer and warns.
    func placeTile(pos: ChunkTilePos, type: TileType) {
        let layer = getNextFreeLayerAt(pos: pos) ?? {
            let layer = Chunk.numLayers - 1
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            Logger.warn("tried to place tile of type '\(type)' at \(pos) but there are no free layers - removing '\(self[pos3D])'")
            return layer
        }()
        let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
        self[pos3D] = type
    }

    func removeTile(pos3D: ChunkTilePos3D) {
        let tileType = self[pos3D]

        // Remove metadata
        tileBehaviors[pos3D] = nil

        // Remove tile
        tiles.remove(at: pos3D)

        // Notify observers
        _didChangeTile.publish((pos3D: pos3D, oldType: tileType))
    }
    // endregion

    func clone() -> Chunk {
        let clone = Chunk()
        clone.tiles = tiles
        clone.tileBehaviors = tileBehaviors.mapValues { tileBehavior in
            tileBehavior.clonePermanent()
        }
        return clone
    }

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case tileData
        case tileMetadatas
    }

    struct MetadataCodingKey: CodingKey {
        let index: Int

        var intValue: Int? { index }
        var stringValue: String { index.description }

        init?(stringValue: String) {
            if let index = Int(stringValue) {
                self.init(index: index)
            } else {
                return nil
            }
        }

        init?(intValue: Int) {
            self.init(index: intValue)
        }

        init(index: Int) {
            self.index = index
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let tileData = try container.decode(Data.self, forKey: .tileData)
        if tileData.count != ChunkMatrix<TileType>.sizeAsData {
            throw DecodingError.dataCorruptedError(forKey: .tileData, in: container, debugDescription: "tile data size is wrong: expected \(ChunkMatrix<TileType>.sizeAsData) got \(tileData.count)")
        }
        tiles.decode(from: tileData)

        let encodedMetadatasAndPositions = try container.decode([JSON].self, forKey: .tileMetadatas)
        for encodedMetadataAndPos3D in encodedMetadatasAndPositions {
            try DecodeTileMetadataFromJson(json: encodedMetadataAndPos3D) { pos3D in
                let tileType = tiles[pos3D]
                // Might be nil
                let tileBehavior = tileType.bigType.newBehavior()
                tileBehaviors[pos3D] = tileBehavior
                return tileBehavior
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let tileData = tiles.toData
        try container.encode(tileData, forKey: .tileData)

        let encodedMetadatasAndPositions = try sortedTileBehaviors.map { (pos, tileBehavior) in
            try EncodeTileMetadataToJson(pos: pos, tileBehavior: tileBehavior)
        }
        try container.encode(encodedMetadatasAndPositions, forKey: .tileMetadatas)
    }
    // endregion
}
