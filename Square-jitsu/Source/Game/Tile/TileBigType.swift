//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// - Note: Try to put all pattern matching on TileBigType here, so it's easier to add new cases
enum TileBigType: UInt16, CaseIterable, Codable, LosslessStringConvertibleEnum {
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
    case projectile

    // Entity / tile hybrids (both tile and entity representations are used)
    case turret

    // --- Pattern matching below

    var layer: TileLayer {
        switch self {
        case .air:
            return .air
        case .background, .overlapSensitiveBackground:
            return .background
        case .solid, .adjacentSensitiveSolid:
            return .solid
        case .ice:
            return .iceSolid
        case .player, .enemy, .shuriken, .projectile, .turret:
            return .entity
        }
    }

    func newMetadata() -> TileMetadata? {
        switch self {
        case .air, .background, .solid, .adjacentSensitiveSolid, .overlapSensitiveBackground, .ice:
            return nil
        case .projectile:
            // Not a tile
            return nil
        case .player:
            return PlayerSpawnMetadata()
        case .enemy:
            return SingleSpawnInRadiusMetadata()
        case .shuriken:
            return SpawnOnGrabMetadata()
        case .turret:
            return TurretMetadata()
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

    // TODO: Remove this and go back to encoding / decoding as integer after switching component encoding / decoding to use settings

    init?(_ description: String) {
        if let bigType = TileBigType.typesByName[description] {
            self = bigType
        } else {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let this = TileBigType(try container.decode(String.self)) {
            self = this
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "String isn't a valid big-type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
