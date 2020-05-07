//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum TileBigType: UInt16 {
    case air
    case background
    case solid
    case ice

    case shurikenSpawn
    case enemySpawn
    case playerSpawn

    var layer: TileLayer {
        switch self {
        case .air:
            return TileLayer.air
        case .background:
            return TileLayer.background
        case .solid, .ice:
            return TileLayer.foreground
        case .shurikenSpawn, .enemySpawn, .playerSpawn:
            return TileLayer.spawn
        }
    }

    static func typesCanOverlap(_ lhs: TileBigType, _ rhs: TileBigType) -> Bool {
        TileLayer.layersCanOverlap(lhs.layer, rhs.layer)
    }
}
