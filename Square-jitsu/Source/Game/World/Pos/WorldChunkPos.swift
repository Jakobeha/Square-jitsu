//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct WorldChunkPos: Equatable, Hashable {
    static func +(lhs: WorldChunkPos, offset: RelativePos) -> WorldChunkPos {
        WorldChunkPos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    let x: Int
    let y: Int

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
