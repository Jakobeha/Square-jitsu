//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

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
    case destructibleSolid
    case ice

    case backgroundDirectionBoost

    case solidEdge
    case dashEdge
    case springEdge
    case lava

    // Entities
    case player
    case enemy
    case shuriken
    case bomb
    case projectile

    // Entity / tile hybrids (both tile and entity representations are used)
    case turret

    // Explosion - should be last so it's displayed over everything else
    case explosion

    case image
    case portal
    case button

    case glassSolid
    case cameraBoundary

    case coin
    case key

    case filler

    // region pattern matching
    var layer: TileLayer {
        switch self {
        case .air:
            return .air
        case .background,
             .overlapSensitiveBackground:
            return .background
        case .backgroundDirectionBoost:
            return .backgroundDirectionBoost
        case .solid,
             .adjacentSensitiveSolid,
             .destructibleSolid,
             .button,
             .glassSolid:
             return .solid
        case .ice:
            return .iceSolid
        case .solidEdge,
             .dashEdge,
             .springEdge,
             .lava:
            return .edge
        case .image,
             .portal,
             .cameraBoundary,
             .filler:
            return .free
        case .coin, .key:
            return .collectible
        case .player,
             .enemy,
             .shuriken,
             .bomb,
             .projectile,
             .turret,
             .explosion:
            return .entity
        }
    }

    func newMetadataSetting() -> SerialSetting {
        switch self {
        case .air,
             .background,
             .overlapSensitiveBackground,
             .solid,
             .adjacentSensitiveSolid,
             .destructibleSolid,
             .ice,
             .backgroundDirectionBoost,
             .solidEdge,
             .dashEdge,
             .springEdge,
             .lava,
             .player,
             .enemy,
             .shuriken,
             .bomb,
             .projectile,
             .explosion,
             .button,
             .glassSolid,
             .cameraBoundary,
             .coin,
             .key,
             .filler:
            return NeverSetting()
        case .turret:
            return TurretMetadata.newSetting()
        case .image:
            return ImageMetadata.newSetting()
        case .portal:
            return PortalMetadata.newSetting()
        }
    }

    func newBehavior() -> TileBehavior? {
        switch self {
        case .air,
             .background,
             .solid,
             .adjacentSensitiveSolid,
             .overlapSensitiveBackground,
             .ice,
             .backgroundDirectionBoost,
             .solidEdge,
             .lava,
             .cameraBoundary,
             .filler:
            return nil
        case .destructibleSolid,
             .glassSolid:
            return DestructibleBehavior()
        case .dashEdge:
            return DashBehavior()
        case .springEdge:
            return SpringBehavior()
        case .projectile, .explosion:
            // Can still be called on bad maps, so we don't error
            Logger.warn("newBehavior called on non-tile \(self)")
            return nil
        case .player:
            return PlayerSpawnBehavior()
        case .enemy:
            return SingleSpawnInRadiusBehavior()
        case .shuriken, .bomb:
            return SpawnOnGrabBehavior()
        case .turret:
            return TurretBehavior()
        case .image:
            return ImageBehavior()
        case .portal:
            return PortalBehavior()
        case .button:
            return ButtonBehavior()
        case .coin, .key:
            return CollectibleBehavior()
        }
    }

    var asCollectibleType: CollectibleType? {
        switch self {
        case .coin:
            return .coin
        case .key:
            return .key
        default:
            return nil
        }
    }

    var canBeSelected: Bool {
        switch self {
        case .air:
            return false
        default:
            return true
        }
    }

    private var explicitZPosition: CGFloat? {
        switch self {
        case .portal:
            return TileBigType.player.zPosition - TileType.smallestZPositionOffset
        default:
            return nil
        }
    }
    // endregion
    
    var zPosition: CGFloat {
        explicitZPosition ?? implicitZPosition
    }

    private var implicitZPosition: CGFloat {
        layer.zPosition + (CGFloat(rawValue) / CGFloat(TileBigType.allCases.count))
    }

    // region encoding and decoding
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

    // endregion
}
