//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkTilePos3D: Equatable, Hashable, CaseIterable {
    let pos: ChunkTilePos
    let layer: Int

    static let allCases: [ChunkTilePos3D] = {
        ChunkTilePos.allCases.flatMap { pos in
            (0..<Chunk.numLayers).map { layer in
                ChunkTilePos3D(pos: pos, layer: layer)
            }
        }
    }()
}
