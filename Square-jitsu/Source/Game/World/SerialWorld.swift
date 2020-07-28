//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Implementation of a serialized world. `WorldFile` should usually be used instead.
class SerialWorld {
    private struct Serialized: Codable {
        enum CodingKeys: String, CodingKey {
            case version
            case settings
            case background
            case positions
            case chunks
        }

        var version: SerialWorldVersion {
            SerialWorldVersion.latest
        }

        var settings: String
        var background: String
        var positions: [WorldChunkPos]
        var chunks: [Chunk]

        init(settings: String, backgroundName: String, chunksAtPositions: [WorldChunkPos:Chunk]) {
            self.settings = settings
            self.background = backgroundName
            // We want the closest positions to be encoded / decoded first,
            // and chunk positions are explicitly ordered so that closer positions
            // are usually "less than" further ones
            positions = chunksAtPositions.keys.sorted { $0 < $1 }
            chunks = positions.map { position in chunksAtPositions[position]! }
        }

        func finishDecodingChunks() -> [WorldChunkPos: Chunk] {
            [WorldChunkPos: Chunk](uniqueKeysWithValues: zip(positions, chunks))
        }

        func validate() throws {
            if positions.count != chunks.count {
                throw ChunkDecodingError.differentLengths(positionsLength: positions.count, chunksLength: chunks.count)
            }
            if positions.hasDuplicates {
                throw ChunkDecodingError.duplicatePositions(positions: positions)
            }
            if WorldSettingsManager.all[settings] == nil {
                throw DecodeSettingError.invalidOption(myOption: settings, validOptions: [String](WorldSettingsManager.all.keys))
            }
            if BackgroundWorldLoaders.all[background] == nil {
                throw DecodeSettingError.invalidOption(myOption: background, validOptions: [String](BackgroundWorldLoaders.all.keys))
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let version = try container.decode(SerialWorldVersion.self, forKey: .version)
            settings = try container.decode(String.self, forKey: .settings)
            background = try container.decode(String.self, forKey: .background)
            positions = try container.decode([WorldChunkPos].self, forKey: .positions)
            if version > ._0_1_1 {
                chunks = try container.decode([Chunk].self, forKey: .chunks)
            } else {
                let oldChunks = try container.decode([ChunkV_0_1_1].self, forKey: .chunks)
                chunks = oldChunks.map { oldChunk in oldChunk.upgraded }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(version, forKey: .version)
            try container.encode(settings, forKey: .settings)
            try container.encode(background, forKey: .background)
            try container.encode(positions, forKey: .positions)
            try container.encode(chunks, forKey: .chunks)
        }
    }

    private static let decoder: JSONDecoder = JSONDecoder()
    private static let encoder: JSONEncoder = JSONEncoder()

    var settingsName: String
    var backgroundName: String
    var chunks: [WorldChunkPos:Chunk]

    init() {
        settingsName = WorldSettingsManager.defaultName
        backgroundName = BackgroundWorldLoaders.emptyName
        chunks = [:]
    }

    init(from data: Data) throws {
        let serialized = try SerialWorld.decoder.decode(Serialized.self, from: data)
        try serialized.validate()

        settingsName = serialized.settings
        backgroundName = serialized.background
        chunks = serialized.finishDecodingChunks()
    }

    func encode() throws -> Data {
        let serialized = Serialized(settings: settingsName, backgroundName: backgroundName, chunksAtPositions: chunks)
        return try SerialWorld.encoder.encode(serialized)
    }
}
