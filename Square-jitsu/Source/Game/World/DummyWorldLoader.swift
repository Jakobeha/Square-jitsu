//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class DummyWorldLoader : WorldLoader {
    let playerSpawnChunkPos: WorldChunkPos = WorldChunkPos(x: 0, y: 0)

    func loadChunk(pos: WorldChunkPos) -> Chunk {
        let solidType = pos.x % 2 == 0 ? TileType.basicSolid : TileType.basicAdjacentSensitiveSolid
        let backgroundType = pos.y % 2 == 0 ? TileType.basicBackground : TileType.basicOverlapSensitiveBackground

        let chunk = Chunk()
        for x in 0..<Chunk.widthHeight {
            if x != Chunk.widthHeight - 3 {
                for y in 0..<2 {
                    let pos = ChunkTilePos(x: x, y: y)
                    chunk.forcePlaceTile(pos: pos, type: solidType)
                }
                for y in 10..<11 {
                    let pos = ChunkTilePos(x: x, y: y)
                    chunk.forcePlaceTile(pos: pos, type: solidType)
                }
            }
        }
        for y in 5..<10 {
            let pos = ChunkTilePos(x: 3, y: y)
            chunk.forcePlaceTile(pos: pos, type: TileType.basicIce)
        }
        for x in 19..<28 {
            for y in (29 - x)..<10 {
                let pos = ChunkTilePos(x: x, y: y)
                chunk.forcePlaceTile(pos: pos, type: backgroundType)
            }
        }
        for y in 2..<5 {
            let pos = ChunkTilePos(x: 28, y: y)
            chunk.forcePlaceTile(pos: pos, type: solidType)
        }
        chunk.forcePlaceTile(pos: ChunkTilePos(x: 17, y: 2), type: TileType.enemySpawn)
        chunk.forcePlaceTile(pos: ChunkTilePos(x: 12, y: 7), type: TileType.shurikenSpawn)
        if pos == playerSpawnChunkPos {
            chunk.forcePlaceTile(pos: ChunkTilePos(x: 6, y: 4), type: TileType.playerSpawn)
        }
        return chunk
    }
}
