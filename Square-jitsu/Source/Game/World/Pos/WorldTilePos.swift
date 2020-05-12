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

    var worldChunkPos: WorldChunkPos {
        WorldChunkPos(x: x.floorQuotient(dividingBy: Chunk.widthHeight), y: y.floorQuotient(dividingBy: Chunk.widthHeight))
    }

    var chunkTilePos: ChunkTilePos {
        ChunkTilePos(x: x.positiveRemainder(dividingBy: Chunk.widthHeight), y: y.positiveRemainder(dividingBy: Chunk.widthHeight))
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    var cornerAdjacents: DenseEnumMap<Corner, WorldTilePos> {
        DenseEnumMap { corner in self + corner.offset }
    }

    var sideAdjacents: DenseEnumMap<Side, WorldTilePos> {
        DenseEnumMap { side in self + side.offset }
    }

    init(worldChunkPos: WorldChunkPos, chunkTilePos: ChunkTilePos) {
        self.init(
                x: (worldChunkPos.x * Chunk.widthHeight) + chunkTilePos.x,
                y: (worldChunkPos.y * Chunk.widthHeight) + chunkTilePos.y
        )
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}