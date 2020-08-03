//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// A world with just the player at (0, 0)
struct EmptyWorldLoader: WorldLoader {
    var playerSpawnChunkPos: WorldChunkPos { WorldChunkPos(x: 0, y: 0) }

    func loadChunk(pos: WorldChunkPos) -> Chunk {
        let chunk = Chunk()
        if pos == WorldChunkPos(x: 0, y: 0) {
            chunk.placeTile(pos: ChunkTilePos(x: 0, y: 0), type: TileType.player, force: true)
        }

        return chunk
    }
}
