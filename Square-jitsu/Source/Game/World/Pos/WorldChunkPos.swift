//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

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
}
