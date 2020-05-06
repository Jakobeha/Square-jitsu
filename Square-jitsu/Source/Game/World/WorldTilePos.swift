//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct WorldTilePos: Equatable, Hashable {
    static func closestTo(pos: CGPoint) -> WorldTilePos {
        WorldTilePos(x: Int(pos.x.rounded()), y: Int(pos.y.rounded()))
    }

    static func +(lhs: WorldTilePos, offset: RelativePos) -> WorldTilePos {
        WorldTilePos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    let x: Int
    let y: Int

    // TODO: Validate / and % as used here don't create overlaps
    var worldChunkPos: WorldChunkPos {
        WorldChunkPos(x: x / Chunk.widthHeight, y: y / Chunk.widthHeight)
    }

    var chunkTilePos: ChunkTilePos {
        ChunkTilePos(x: x % Chunk.widthHeight, y: y % Chunk.widthHeight)
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    var adjacents: [Corner : WorldTilePos] {
        Corner.allCases.associateWith { corner in
            self + corner.offset
        }
    }
}
