//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Chunk: ReadonlyChunk, Codable {
    static let widthHeight: Int = 32
    static let numLayers: Int = 4

    static let cgSize: CGSize = CGSize.square(sideLength: CGFloat(widthHeight))
    static let extraDistanceFromEntityToUnload: CGFloat = CGFloat(widthHeight) / 2

    private var tiles: ChunkMatrix<TileType> = ChunkMatrix()
    var tileMetadatas: [ChunkTilePos3D:TileMetadata] = [:]
    private var sortedTileMetadatas: [(key: ChunkTilePos3D, value: TileMetadata)] {
        tileMetadatas.sorted { $0.key < $1.key }
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
                tileMetadatas[pos3D] = nil
            }

            // Place metadata if necessary
            if metadataIsDifferent {
                if let newMetadata = newValue.bigType.newMetadata() {
                    tileMetadatas[pos3D] = newMetadata
                }
            }

            // Notify observers of change
            _didChangeTile.publish((pos3D: pos3D, oldType: oldType))
        }
    }

    func getMetadatasAt(pos: ChunkTilePos) -> [(layer: Int, tileMetadata: TileMetadata)] {
        (0..<Chunk.numLayers).compactMap { layer in
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            if let tileMetadata = tileMetadatas[pos3D]  {
                return (layer: layer, tileMetadata: tileMetadata)
            } else {
                return nil
            }
        }
    }

    /// Places the tile, removing any non-overlapping tiles
    /// - Returns: The layer of the tile which was placed
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    @discardableResult func forcePlaceTile(pos: ChunkTilePos, type: TileType) -> Int {
        removeNonOverlappingTiles(pos: pos, type: type)
        assert(tiles.hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
        return placeTile(pos: pos, type: type)
    }

    /// - Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    ///   deletes the tile, while "remove" may mean it was unloaded
    func removeTiles(pos: ChunkTilePos) {
        let tilesAtPos = self[pos]

        // Remove metadatas
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            tileMetadatas[pos3D] = nil
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

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            let existingType = self[pos3D]
            if (!TileBigType.typesCanOverlap(type.bigType, existingType.bigType)) {
                removeTile(pos3D: pos3D)
            }
        }
    }

    private func removeTile(pos3D: ChunkTilePos3D) {
        let tileType = self[pos3D]

        // Remove metadata
        tileMetadatas[pos3D] = nil

        // Remove tile
        tiles.remove(at: pos3D)

        // Notify observers
        _didChangeTile.publish((pos3D: pos3D, oldType: tileType))
    }

    /// - Returns: The layer of the tile which was placed
    @discardableResult private func placeTile(pos: ChunkTilePos, type: TileType) -> Int {
        // Place tile and add metadata
        let layer = tiles.insert(type, at: pos)
        let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
        if let metadata = type.bigType.newMetadata() {
            tileMetadatas[pos3D] = metadata
        }

        // Notify observers
        _didChangeTile.publish((pos3D: pos3D, oldType: TileType.air))

        return layer
    }
    // endregion

    func clone() -> Chunk {
        let clone = Chunk()
        clone.tiles = tiles
        clone.tileMetadatas = tileMetadatas
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
            try DecodeTileMetadataFrom(json: encodedMetadataAndPos3D) { pos3D in
                let tileType = tiles[pos3D]
                // Might be nil
                let tileMetadata = tileType.bigType.newMetadata()
                tileMetadatas[pos3D] = tileMetadata
                return tileMetadata
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let tileData = tiles.toData
        try container.encode(tileData, forKey: .tileData)

        let encodedMetadatasAndPositions = try sortedTileMetadatas.map { (pos, tileMetadata) in
            try EncodeTileMetadataToJson(pos: pos, tileMetadata: tileMetadata)
        }
        try container.encode(encodedMetadatasAndPositions, forKey: .tileMetadatas)
    }
    // endregion
}
