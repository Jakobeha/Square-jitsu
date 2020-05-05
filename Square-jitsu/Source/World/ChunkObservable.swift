//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ChunkObservable {
    var willRemoveTile: Observable<(pos: ChunkTilePos, layer: Int, tile: Tile)> { get }
    var willPlaceTile: Observable<(pos: ChunkTilePos, layer: Int, tile: Tile)> { get }
}
