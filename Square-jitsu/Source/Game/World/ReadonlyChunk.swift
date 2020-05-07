//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyChunk {
    var willRemoveTile: Observable<(pos: ChunkTilePos3D, tileType: TileType)> { get }
    var willPlaceTile: Observable<(pos: ChunkTilePos, tileType: TileType)> { get }

    subscript(_ pos: ChunkTilePos) -> [TileType] { get }
}
