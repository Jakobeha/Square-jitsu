//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class DummyWorldLoader : WorldLoader {
    func loadChunk(pos: WorldChunkPos) -> Chunk {
        let chunk = Chunk()
        for x in 0..<Chunk.widthHeight {
            for y in 0..<2 {
                let pos = ChunkTilePos(x: x, y: y)
                chunk.forcePlaceTile(pos: pos, type: TileType.basicSolid)
            }
            for y in 10..<11 {
                let pos = ChunkTilePos(x: x, y: y)
                chunk.forcePlaceTile(pos: pos, type: TileType.basicSolid)
            }
        }
        for y in 1..<10 {
            let pos = ChunkTilePos(x: 9, y: y)
            chunk.forcePlaceTile(pos: pos, type: TileType.basicIce)
        }
        for x in 22..<30 {
            for y in 2..<10 {
                let pos = ChunkTilePos(x: x, y: y)
                chunk.forcePlaceTile(pos: pos, type: TileType.basicBackground)
            }
        }
        chunk.forcePlaceTile(pos: ChunkTilePos(x: 12, y: 2), type: TileType.playerSpawn)
        chunk.forcePlaceTile(pos: ChunkTilePos(x: 17, y: 2), type: TileType.basicEnemySpawn)
        chunk.forcePlaceTile(pos: ChunkTilePos(x: 20, y: 7), type: TileType.basicShurikenSpawn)
        return chunk
    }
}
