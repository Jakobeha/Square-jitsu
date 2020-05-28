//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ChunkTilePos: Equatable, Comparable, Hashable, Codable, CaseIterable {
    static let zero: ChunkTilePos = ChunkTilePos(x: 0, y: 0)

    static let allCases: [ChunkTilePos] = {
        (0..<Chunk.widthHeight).flatMap { x in
            (0..<Chunk.widthHeight).map { y in
                ChunkTilePos(x: x, y: y)
            }
        }
    }()

    static func +(lhs: ChunkTilePos, offset: RelativePos) -> ChunkTilePos {
        ChunkTilePos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    /// Natural order is the same as that in `allCases`
    static func <(lhs: ChunkTilePos, rhs: ChunkTilePos) -> Bool {
        lhs.order < rhs.order
    }

    let x: Int
    let y: Int

    var order: Int {
        x + (y * Chunk.widthHeight)
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    init(x: Int, y: Int) {
        assert(x >= 0 && x < Chunk.widthHeight && y >= 0 && y < Chunk.widthHeight)
        self.x = x
        self.y = y
    }
}
