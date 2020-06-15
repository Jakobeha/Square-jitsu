//
// Created by Jakob Hain on 6/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol WritableStatelessWorld: ReadonlyStatelessWorld {
    subscript(pos3D: WorldTilePos3D) -> TileType { get set }

    func forceCreateTile(pos: WorldTilePos, type: TileType)
    func destroyTiles(pos: WorldTilePos)
    func destroyTile(pos3D: WorldTilePos3D)
}
