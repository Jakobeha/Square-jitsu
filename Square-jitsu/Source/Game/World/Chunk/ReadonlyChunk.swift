//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyChunk {
    var didChangeTile: Observable<(pos3D: ChunkTilePos3D, oldType: TileType)> { get }
    var didAdjacentTileChange: Observable<ChunkTilePos> { get }

    subscript(_ pos: ChunkTilePos) -> [TileType] { get }
    subscript(_ pos: ChunkTilePos3D) -> TileType { get }

    func clone() -> Chunk
}
