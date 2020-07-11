//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Implementation of a serialized world. `WorldFile` should usually be used instead.
class SerialWorld {
    private struct Serialized: Codable {
        var version: SerialWorldVersion
        var settings: String
        var background: String
        var positions: [WorldChunkPos]
        var chunks: [Chunk]

        init(settings: String, backgroundName: String, chunksAtPositions: [WorldChunkPos:Chunk]) {
            version = SerialWorldVersion.latest
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

        mutating func update() throws {
            if version < SerialWorldVersion.latest {
                // Currently there is nothing we need to update

                // Update recorded version
                version = SerialWorldVersion.latest
            }
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
        var serialized = try SerialWorld.decoder.decode(Serialized.self, from: data)
        try serialized.validate()
        try serialized.update()

        settingsName = serialized.settings
        backgroundName = serialized.background
        chunks = serialized.finishDecodingChunks()
    }

    func encode() throws -> Data {
        let serialized = Serialized(settings: settingsName, backgroundName: backgroundName, chunksAtPositions: chunks)
        return try SerialWorld.encoder.encode(serialized)
    }
}
