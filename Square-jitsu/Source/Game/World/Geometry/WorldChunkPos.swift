//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct WorldChunkPos: Equatable, Comparable, Hashable, Codable {
    static func +(lhs: WorldChunkPos, offset: RelativePos) -> WorldChunkPos {
        WorldChunkPos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    /// Order is equivalent to that of `ChunkPosition.order`
    static func <(lhs: WorldChunkPos, rhs: WorldChunkPos) -> Bool {
        lhs.order < rhs.order
    }

    let x: Int
    let y: Int

    /// Determines the `Comparable` order of chunk positions. 0 is the chunk at (0, 0),
    /// and the rest of the sequence forms a counter-clockwise spiral outwards starting at (1, 0)
    var order: Float {
        let distance = max(x, y)
        let angle = CGPoint(x: x, y: y).directionFromOrigin.positiveRadians
        let angleFraction = (Float.pi * 2) / angle
        return Float(distance) + angleFraction
    }

    var adjacents: [Corner : WorldChunkPos] {
        Corner.allCases.associateWith { corner in
            self + corner.offset
        }
    }

    var originCgPoint: CGPoint {
        CGPoint(x: CGFloat(x * Chunk.widthHeight), y: CGFloat(y * Chunk.widthHeight))
    }

    var cgBounds: CGRect {
        CGRect(origin: originCgPoint, size: Chunk.cgSize)
    }
}
