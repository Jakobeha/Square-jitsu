//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// - Note: Try to put all pattern matching on TileBigType here, so it's easier to add new cases
enum TileBigType: UInt16, CaseIterable, Codable {
    // Actual tiles
    case air
    case background
    /// Background which changes texture while an entity is collided with it
    case overlapSensitiveBackground
    case solid
    /// Solid which changes texture while an entity is collided with it
    case adjacentSensitiveSolid
    case ice

    // Entities
    case player
    case enemy
    case shuriken

    // Entity / tile hybrids (both tile and entity representations are used)
    case turret

    // --- Pattern matching below

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
        case .player, .enemy, .shuriken:
            return TileLayer.entity
        case .turret:
            return TileLayer.entity
        }
    }

    func newMetadata() -> TileMetadata? {
        switch self {
        case .air, .background, .solid, .adjacentSensitiveSolid, .overlapSensitiveBackground, .ice:
            return nil
        case .player:
            return PlayerSpawnMetadata()
        case .enemy:
            return SingleSpawnInRadiusMetadata()
        case .shuriken:
            return SpawnOnGrabMetadata()
        case .turret:
            fatalError("TODO implement")
        }
    }

    // --- End pattern matching

    static func typesCanOverlap(_ lhs: TileBigType, _ rhs: TileBigType) -> Bool {
        TileLayer.layersCanOverlap(lhs.layer, rhs.layer)
    }

    var description: String { String(describing: self) }

    private static let typesByName: [String:TileBigType] = [String:TileBigType](
            uniqueKeysWithValues: allCases.map { bigType in (key: bigType.description, value: bigType) }
    )

    init?(_ description: String) {
        if let bigType = TileBigType.typesByName[description] {
            self = bigType
        } else {
            return nil
        }
    }
}
