//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class GamePersistentChunkData {
    var overwrittenTiles: [ChunkTilePos3D:TileType] = [:]

    func apply(to chunk: Chunk) {
        for (chunkPos3D, overwrittenTileType) in overwrittenTiles {
            chunk[chunkPos3D] = overwrittenTileType
        }
    }
}
