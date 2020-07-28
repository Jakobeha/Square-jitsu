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

    /// Places the tile if there are no overlapping tiles
    /// - Returns: The layer of the tile if it was placed, otherwise nil
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    @discardableResult func tryPlaceTile(pos: ChunkTilePos, type: TileType) -> Int? {
        if type.isMeaninglessInGame {
            return nil
        } else {
            if let layer = getLayerWithSameNotOrientedType(pos: pos, type: type.withDefaultOrientation) {
                if type.bigType.layer.doTilesOccupySides {
                    let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
                    self[pos3D].orientation.asSideSet.formUnion(type.orientation.asSideSet)
                    return layer
                } else {
                    return nil
                }
            } else {
                if !hasOverlappingTiles(pos: pos, type: type) {
                    assert(tiles.hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
                    return placeTile(pos: pos, type: type)
                } else {
                    return nil
                }
            }
        }
    }

    /// Places the tile, removing any non-overlapping tiles. The tile still won't be placed if it's meaningless
    /// (e.g. a tile which functions based on its orientation, but has none)
    /// - Returns: The layer of the tile if it was placed, otherwise nil
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    @discardableResult func forcePlaceTile(pos: ChunkTilePos, type: TileType) -> Int? {
        if type.isMeaninglessInGame {
            return nil
        } else {
            if let layer = getLayerWithSameNotOrientedType(pos: pos, type: type.withDefaultOrientation) {
                let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
                self[pos3D] = self[pos3D].mergedOrReplaced(orientation: type.orientation)
                return layer
            } else {
                removeNonOverlappingTiles(pos: pos, type: type)
                assert(tiles.hasFreeLayerAt(pos: pos), "removed tiles to place a tile of type '\(type)', but there are still no free layers")
                return placeTile(pos: pos, type: type)
            }
        }
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

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            let existingType = self[pos3D]
            if !TileType.typesCanOverlap(type, existingType) {
                removeTile(pos3D: pos3D)
            }
        }

        // Still need to remove a tile if there is no free chunk layer.
        // We could remove one at any layer (all layers are occupied), but we choose the last one
        if !tiles.hasFreeLayerAt(pos: pos) {
            removeTile(pos3D: ChunkTilePos3D(pos: pos, layer: Chunk.numLayers - 1))
        }
    }

    private func removeTile(pos3D: ChunkTilePos3D) {
        let tileType = self[pos3D]

        // Remove metadata
        tileBehaviors[pos3D] = nil

        // Remove tile
        tiles.remove(at: pos3D)

        // Notify observers
        _didChangeTile.publish((pos3D: pos3D, oldType: tileType))
    }

    private func hasOverlappingTiles(pos: ChunkTilePos, type: TileType) -> Bool {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            let existingType = self[pos3D]
            if !TileType.typesCanOverlap(type, existingType) {
                return true
            }
        }
        return false
    }

    /// - Returns: The layer of the tile which was placed
    @discardableResult private func placeTile(pos: ChunkTilePos, type: TileType) -> Int {
        // Place tile and add metadata
        let layer = tiles.insert(type, at: pos)
        let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
        if let metadata = type.bigType.newBehavior() {
            tileBehaviors[pos3D] = metadata
        }

        // Notify observers
        _didChangeTile.publish((pos3D: pos3D, oldType: TileType.air))

        return layer
    }

    private func getLayerWithSameNotOrientedType(pos: ChunkTilePos, type: TileType) -> Int? {
        assert(type.withDefaultOrientation == type)
        return self[pos].firstIndex { otherType in otherType.withDefaultOrientation == type }
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
