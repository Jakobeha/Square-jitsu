//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol WorldLoader {
    var playerSpawnChunkPos: WorldChunkPos { get }

    func loadChunk(pos: WorldChunkPos) -> Chunk
}
