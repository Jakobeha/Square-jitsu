//
// Created by Jakob Hain on 7/25/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class ChunkV_0_1_1: Codable {
    static let widthHeight: Int = 32
    static let numLayers: Int = 8

    private var tiles: ChunkMatrixV_0_1_1<TileType> = ChunkMatrixV_0_1_1()
    var tileBehaviors: [ChunkTilePos3DV_0_1_1:TileBehavior] = [:]
    private var sortedTileBehaviors: [(key: ChunkTilePos3DV_0_1_1, value: TileBehavior)] {
        tileBehaviors.sorted { $0.key < $1.key }
    }

    init() {}

    var upgraded: Chunk {
        let chunk = Chunk()
        for pos3d in ChunkTilePos3D.allCases {
            let myPos3d = ChunkTilePos3DV_0_1_1(pos3d)
            chunk[pos3d] = self[myPos3d]
            chunk.tileBehaviors[pos3d] = tileBehaviors[myPos3d]
        }
        return chunk
    }

    subscript(_ pos3D: ChunkTilePos3DV_0_1_1) -> TileType {
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
        }
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
        if tileData.count != ChunkMatrixV_0_1_1<TileType>.sizeAsData {
            throw DecodingError.dataCorruptedError(forKey: .tileData, in: container, debugDescription: "tile data size is wrong: expected \(ChunkMatrixV_0_1_1<TileType>.sizeAsData) got \(tileData.count)")
        }
        tiles.decode(from: tileData)

        let encodedMetadatasAndPositions = try container.decode([JSON].self, forKey: .tileMetadatas)
        for encodedMetadataAndPos3D in encodedMetadatasAndPositions {
            try DecodeTileMetadataFromJsonV_0_1_1(json: encodedMetadataAndPos3D) { pos3D in
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
            try EncodeTileMetadataToJsonV_0_1_1(pos: pos, tileBehavior: tileBehavior)
        }
        try container.encode(encodedMetadatasAndPositions, forKey: .tileMetadatas)
    }
    // endregion
}
