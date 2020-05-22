//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum ChunkDecodingError: Error, CustomStringConvertible {
    case differentLengths(positionsLength: Int, chunksLength: Int)
    case duplicatePositions(positions: [WorldChunkPos])

    var description: String {
        switch self {
        case .differentLengths(let positionsLength, let chunksLength):
            return "different lengths of positions and chunks: \(positionsLength) != \(chunksLength)"
        case .duplicatePositions(let positions):
            return "duplicate chunk positions (all of them are \(positions))"
        }
    }
}