//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol ReadonlyChunk {
    var didRemoveTile: Observable<(pos3D: ChunkTilePos3D, oldType: TileType)> { get }
    var didPlaceTile: Observable<ChunkTilePos3D> { get }

    subscript(_ pos: ChunkTilePos) -> [TileType] { get }
    subscript(_ pos: ChunkTilePos3D) -> TileType { get }

    /// Places all tiles on the other chunk, overwriting its tiles
    func placeOnTopOf(otherChunk: Chunk)
}
