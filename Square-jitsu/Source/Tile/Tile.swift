//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Tile: Equatable {
    static let air: Tile = Tile(type: TileType.air, id: TileId.anonymous)
    static let basicSolid: Tile = Tile(type: TileType.basicSolid, id: TileId.anonymous)

    let type: TileType
    let id: TileId
}
