//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileType: Equatable {
    static let air: TileType = TileType(bigType: TileBigType.air, smallType: TileSmallType.air)
    static let basicBackground: TileType = TileType(bigType: TileBigType.solid, smallType: TileSmallType.backgroundBasic)
    static let basicSolid: TileType = TileType(bigType: TileBigType.solid, smallType: TileSmallType.solidBasic)
    static let basicIce: TileType = TileType(bigType: TileBigType.ice, smallType: TileSmallType.iceBasic)
    static let basicShurikenSpawn: TileType = TileType(bigType: TileBigType.shurikenSpawn, smallType: TileSmallType.shurikenSpawnBasic)
    static let basicEnemySpawn: TileType = TileType(bigType: TileBigType.enemySpawn, smallType: TileSmallType.enemySpawnBasic)
    static let playerSpawn: TileType = TileType(bigType: TileBigType.playerSpawn, smallType: TileSmallType.playerSpawn)

    let bigType: TileBigType
    let smallType: TileSmallType

    static func typesCanOverlap(_ lhs: TileType, _ rhs: TileType) -> Bool {
        fatalError("typesCanOverlap(_:_:) has not been implemented")
    }
}
