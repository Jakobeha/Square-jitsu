//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Adapts a world file into a world loader - yet another abstraction on world files.
struct WorldLoaderFromFile: WorldLoader {
    private let file: WorldFile

    var playerSpawnChunkPos: WorldChunkPos { WorldChunkPos(x: 0, y: 0) }

    init(file: WorldFile) {
        self.file = file
    }
    
    func loadChunk(pos: WorldChunkPos) -> Chunk {
        file.readChunkAt(pos: pos).clone()
    }
}
