//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileType: Equatable, HasDefault {
    static let air: TileType = TileType(bigType: TileBigType.air)
    static let basicBackground: TileType = TileType(bigType: TileBigType.solid)
    static let basicSolid: TileType = TileType(bigType: TileBigType.solid)
    static let basicIce: TileType = TileType(bigType: TileBigType.ice)
    static let basicShurikenSpawn: TileType = TileType(bigType: TileBigType.shurikenSpawn)
    static let basicEnemySpawn: TileType = TileType(bigType: TileBigType.enemySpawn)
    static let playerSpawn: TileType = TileType(bigType: TileBigType.playerSpawn)

    static let defaultValue: TileType = air

    let bigType: TileBigType
    let smallType: TileSmallType
    let orientation: TileOrientation

    var isDefault: Bool { self == TileType.defaultValue }

    init(bigType: TileBigType, smallType: TileSmallType = TileSmallType._0, orientation: TileOrientation = TileOrientation.none) {
        self.bigType = bigType
        self.smallType = smallType
        self.orientation = orientation
    }
}
