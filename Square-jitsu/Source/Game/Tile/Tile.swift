//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Tile: HasDefault, Equatable {
    static let air: Tile = Tile(type: TileType.air, id: TileId.anonymous)
    static let basicSolid: Tile = Tile(type: TileType.basicSolid, id: TileId.anonymous)

    static let defaultValue: Tile = Tile.air

    let type: TileType
    let id: TileId

    var isDefault: Bool { self == Tile.air }
}
