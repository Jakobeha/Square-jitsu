//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyChunk {
    var willRemoveTile: Observable<(pos: ChunkTilePos, layer: Int, tile: Tile)> { get }
    var willPlaceTile: Observable<(pos: ChunkTilePos, tile: Tile)> { get }

    subscript(_ pos: ChunkTilePos) -> [Tile] { get }
}
