//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkTilePos: Equatable, Hashable {
    static func +(lhs: ChunkTilePos, offset: RelativePos) -> ChunkTilePos {
        ChunkTilePos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        assert(x > 0 && x < Chunk.widthHeight && y > 0 && y < Chunk.widthHeight)
        self.x = x
        self.y = y
    }
}
