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

    private let _didRemoveTile: Publisher<(pos3D: ChunkTilePos3D, oldType: TileType)> = Publisher()
    private let _didPlaceTile: Publisher<ChunkTilePos3D> = Publisher()
    var didRemoveTile: Observable<(pos3D: ChunkTilePos3D, oldType: TileType)> { Observable(publisher: _didRemoveTile) }
    var didPlaceTile: Observable<ChunkTilePos3D> { Observable(publisher: _didPlaceTile) }

    init() {}

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

            // Notify observers of removal
            _didRemoveTile.publish((pos3D: pos3D, oldType: oldType))

            // Place metadata if necessary
            if metadataIsDifferent {
                if let newMetadata = newValue.bigType.newMetadata() {
                    tileMetadatas[pos3D] = newMetadata
                }
            }

            // Notify observers of placement
            _didPlaceTile.publish(pos3D)
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

    /// Places all tiles on the other chunk, overwriting its tiles
    func placeOnTopOf(otherChunk: Chunk) {
        for chunkTilePos in ChunkTilePos.allCases {
            let tileTypes = self[chunkTilePos].filter { tileType in tileType != TileType.air }
            for tileType in tileTypes {
                otherChunk.removeNonOverlappingTiles(pos: chunkTilePos, type: tileType)
            }
            for tileType in tileTypes {
                otherChunk.placeTile(pos: chunkTilePos, type: tileType)
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
            _didRemoveTile.publish((pos3D: pos3D, oldType: oldType))
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
        _didRemoveTile.publish((pos3D: pos3D, oldType: tileType))
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
        _didPlaceTile.publish(pos3D)

        return layer
    }

    // ---

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
        let expectedTileDataSize = MemoryLayout.size(ofValue: tiles)
        if tileData.count != expectedTileDataSize {
            throw DecodingError.dataCorruptedError(forKey: .tileData, in: container, debugDescription: "tile data size is wrong: expected \(expectedTileDataSize) got \(tileData.count)")
        }
        (tileData as NSData).getBytes(&tiles, length: expectedTileDataSize)

        let metadatasContainer = try container.nestedContainer(keyedBy: MetadataCodingKey.self, forKey: .tileMetadatas)
        tileMetadatas = [:]
        var nextMetadataIndex: Int = 0
        for chunkTilePos3D in ChunkTilePos3D.allCases {
            let tileType = tiles[chunkTilePos3D]
            if let tileMetadata = tileType.bigType.newMetadata() {
                TileMetadataCodingWrapper.metadataBeingCoded = tileMetadata
                let _ = try metadatasContainer.decode(TileMetadataCodingWrapper.self, forKey: MetadataCodingKey(index: nextMetadataIndex))
                nextMetadataIndex += 1
            }

            if tileType.bigType == TileBigType.player {
                throw DecodingError.dataCorruptedError(forKey: .tileData, in: container, debugDescription: "player tile can't be serialized - currently player position needs to be in the chunk at (0, 0), so it's provided by the background chunk which isn't serialized")
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let tileDataSize = MemoryLayout.size(ofValue: tiles)
        var tileData = Data(count: tileDataSize)
        tileData.withUnsafeMutableBytes { dataPtr in
            dataPtr.storeBytes(of: tiles, as: ChunkMatrix.self)
        }
        try container.encode(tileData, forKey: .tileData)

        var metadatasContainer = container.nestedContainer(keyedBy: MetadataCodingKey.self, forKey: .tileMetadatas)
        var nextMetadataIndex: Int = 0
        for chunkTilePos3D in ChunkTilePos3D.allCases {
            if let tileMetadata = tileMetadatas[chunkTilePos3D] {
                TileMetadataCodingWrapper.metadataBeingCoded = tileMetadata
                try metadatasContainer.encode(TileMetadataCodingWrapper(), forKey: MetadataCodingKey(index: nextMetadataIndex))
                nextMetadataIndex += 1
            }
        }
    }
}
