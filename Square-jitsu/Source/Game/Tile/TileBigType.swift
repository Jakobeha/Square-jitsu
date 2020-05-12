//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum TileBigType: UInt16, CaseIterable {
    case air
    case background
    case overlapSensitiveBackground
    case solid
    /// Solid which changes texture while an entity is collided with it
    case adjacentSensitiveSolid
    case ice

    case playerSpawn
    case enemySpawn
    case shurikenSpawn

    static func typesCanOverlap(_ lhs: TileBigType, _ rhs: TileBigType) -> Bool {
        TileLayer.layersCanOverlap(lhs.layer, rhs.layer)
    }

    var layer: TileLayer {
        switch self {
        case .air:
            return TileLayer.air
        case .background, .overlapSensitiveBackground:
            return TileLayer.background
        case .solid, .adjacentSensitiveSolid:
            return TileLayer.solid
        case .ice:
            return TileLayer.iceSolid
        case .playerSpawn, .enemySpawn, .shurikenSpawn:
            return TileLayer.entity
        }
    }

    func newMetadata() -> TileMetadata? {
        switch (self) {
        case .air, .background, .solid, .adjacentSensitiveSolid, .overlapSensitiveBackground, .ice:
            return nil
        case .playerSpawn:
            return PlayerSpawnMetadata()
        case .enemySpawn:
            return SingleSpawnInRadiusMetadata()
        case .shurikenSpawn:
            return SpawnOnGrabMetadata()
        }
    }
}
