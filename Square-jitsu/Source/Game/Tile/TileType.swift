//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileType: Equatable, Hashable, HasDefault {
    static let air: TileType = TileType(bigType: TileBigType.air)
    static let basicBackground: TileType = TileType(bigType: TileBigType.background)
    static let basicOverlapSensitiveBackground: TileType = TileType(bigType: TileBigType.overlapSensitiveBackground)
    static let basicSolid: TileType = TileType(bigType: TileBigType.solid)
    static let basicAdjacentSensitiveSolid: TileType = TileType(bigType: TileBigType.adjacentSensitiveSolid)
    static let basicIce: TileType = TileType(bigType: TileBigType.ice)
    static let playerSpawn: TileType = TileType(bigType: TileBigType.playerSpawn)
    static let shurikenSpawn: TileType = TileType(bigType: TileBigType.shurikenSpawn)
    static let enemySpawn: TileType = TileType(bigType: TileBigType.enemySpawn)

    static let defaultValue: TileType = air

    let bigType: TileBigType
    let smallType: TileSmallType
    let orientation: TileOrientation

    var isDefault: Bool { self == TileType.defaultValue }

    var isSolid: Bool { bigType.layer == TileLayer.solid || bigType.layer == TileLayer.iceSolid }

    init(bigType: TileBigType, smallType: TileSmallType = TileSmallType(0), orientation: TileOrientation = TileOrientation.none) {
        self.bigType = bigType
        self.smallType = smallType
        self.orientation = orientation
    }
}
