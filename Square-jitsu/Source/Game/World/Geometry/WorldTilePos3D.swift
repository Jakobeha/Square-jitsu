//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct WorldTilePos3D: Equatable, Hashable {
    static let zero: WorldTilePos3D = WorldTilePos3D(pos: WorldTilePos.zero, layer: 0)

    static func +(lhs: WorldTilePos3D, offset: RelativePos) -> WorldTilePos3D {
        WorldTilePos3D(pos: lhs.pos + offset, layer: lhs.layer)
    }

    static func groupByChunkPositions<TilePosCollection: Collection>(_ worldPositions: TilePosCollection) -> [WorldChunkPos:Set<ChunkTilePos3D>] where TilePosCollection.Element == WorldTilePos3D {
        (Dictionary(grouping: worldPositions) { pos3D in pos3D.pos.worldChunkPos }).mapValues { positionsAtWorldChunkPos in
            Set(positionsAtWorldChunkPos.map { pos3D in pos3D.chunkTilePos3D })
        }
    }

    let pos: WorldTilePos
    let layer: Int

    var chunkTilePos3D: ChunkTilePos3D {
        ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)
    }

    init(worldChunkPos: WorldChunkPos, chunkTilePos3D: ChunkTilePos3D) {
        self.init(worldChunkPos: worldChunkPos, chunkTilePos: chunkTilePos3D.pos, layer: chunkTilePos3D.layer)
    }

    init(worldChunkPos: WorldChunkPos, chunkTilePos: ChunkTilePos, layer: Int) {
        self.init(pos: WorldTilePos(worldChunkPos: worldChunkPos, chunkTilePos: chunkTilePos), layer: layer)
    }

    init(pos: WorldTilePos, layer: Int) {
        self.pos = pos
        self.layer = layer
    }
}
