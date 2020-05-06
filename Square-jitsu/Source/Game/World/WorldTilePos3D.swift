//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct WorldTilePos3D {
    let pos: WorldTilePos
    let layer: Int

    init(worldChunkPos: WorldChunkPos, chunkTilePos: ChunkTilePos, layer: Int) {
        self.init(pos: WorldTilePos(worldChunkPos: worldChunkPos, chunkTilePos: chunkTilePos), layer: layer)
    }

    init(pos: WorldTilePos, layer: Int) {
        self.pos = pos
        self.layer = layer
    }
}
