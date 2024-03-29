//
// Created by Jakob Hain on 5/15/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretComponent: SingleSettingCodable, Codable {
    enum RotationPattern: AutoCodable, SingleSettingCodable {
        case neverRotate
        case rotateContinuously(speed: UnclampedAngle)
        case rotateToTarget(speed: UnclampedAngle)
        case rotateToTargetInstantly

        // region encoding and decoding
        typealias AsSetting = ComplexEnumSetting<RotationPattern>

        static func newSetting() -> AsSetting {
            ComplexEnumSetting(cases: [
                "neverRotate": [:],
                "rotateContinuously": [
                    "speed": UnclampedAngleSetting()
                ],
                "rotateToTarget": [
                    "speed": UnclampedAngleSetting()
                ],
                "rotateToTargetInstantly": [:]
            ])
        }
        // endregion
    }

    enum WhenToFire: AutoCodable, CaseIterable, SimpleEnumSettingCodable {
        case alwaysFire
        case fireOnSeek
    }

    enum HowToFire: AutoCodable, SingleSettingCodable {
        case consistent(projectileSpeed: CGFloat, delay: CGFloat)
        case burst(projectileSpeed: CGFloat, delayBetweenBursts: CGFloat, numShotsInBurst: Int, delayInBurst: CGFloat)
        /// Fire a continuous projectile defined by a line (e.g. with a laser).
        /// The line ends when it reaches a projectile defined in `projectileEndTiles`,
        /// or after a set (long) distance
        case continuous(projectileEndTiles: TileTypePred)

        var projectileSpeed: CGFloat? {
            switch self {
            case .consistent(let projectileSpeed, delay: _):
                return projectileSpeed
            case .burst(let projectileSpeed, delayBetweenBursts: _, numShotsInBurst: _, delayInBurst: _):
                return projectileSpeed
            case .continuous(projectileEndTiles: _):
                return nil
            }
        }

        var isContinuous: Bool {
            switch self {
            case .continuous(projectileEndTiles: _):
                return true
            default:
                return false
            }
        }

        /// Raises an error if this isn't continuous fire
        var continuousProjectileEndTiles: TileTypePred {
            switch self {
            case .consistent(projectileSpeed: _, delay: _), .burst(projectileSpeed: _, delayBetweenBursts: _, numShotsInBurst: _, delayInBurst: _):
                fatalError("firing method isn't continuous, so it doesn't have a predicate of projectile end tiles")
            case .continuous(let projectileEndTiles):
                return projectileEndTiles
            }
        }

        // region encoding and decoding
        typealias AsSetting = ComplexEnumSetting<HowToFire>

        static func newSetting() -> AsSetting {
            ComplexEnumSetting(cases: [
                "consistent": [
                    "projectileSpeed": CGFloatRangeSetting(0...128),
                    "delay": CGFloatRangeSetting(0...16)
                ],
                "burst": [
                    "projectileSpeed": CGFloatRangeSetting(0...128),
                    "delayBetweenBursts": CGFloatRangeSetting(0...16),
                    "numShotsInBurst": IntRangeSetting(2...64),
                    "delayInBurst": CGFloatRangeSetting(0...16)
                ],
                "continuous": [
                    "projectileEndTiles": TileTypePredSetting()
                ]
            ])
        }
        // endregion
    }

    enum SpreadPattern: AutoCodable, SingleSettingCodable {
        case fireStraight
        case fireAround(totalNumProjectiles: Int)

        // region encoding and decoding
        typealias AsSetting = ComplexEnumSetting<SpreadPattern>

        static func newSetting() -> AsSetting {
            ComplexEnumSetting(cases: [
                "fireStraight": [:],
                "fireAround": [
                    "totalNumProjectiles": IntRangeSetting(1...32)
                ]
            ])
        }
        // endregion
    }

    enum TargetState {
        case targetNotFound
        case targetFoundSeeking(entity: EntityRef)
        case targetInLineOfFire(entity: EntityRef)

        var target: EntityRef? {
            switch self {
            case .targetNotFound:
                return nil
            case .targetFoundSeeking(let entity):
                return entity
            case .targetInLineOfFire(let entity):
                return entity
            }
        }
    }

    enum FireState {
        case targetNotFound
        case targetFoundNeedToCharge(timeUntilFire: CGFloat)
        case didFireReloading(timeUntilFire: CGFloat)
        case didFireInBurstReloading(timeUntilFire: CGFloat, numShotsLeftInBurstAfterThis: Int)
        case isFiringContinuous(projectiles: [(projectileRef: EntityRef, directionOffset: Angle)])

        var isContinuous: Bool {
            switch self {
            case .isFiringContinuous(projectiles: _):
                return true
            default:
                return false
            }
        }
    }

    static let turretVisibilityRadius: CGFloat = 12
    static let maxLaserDistance: CGFloat = 24

    static let maxRotation: Angle = Angle.right * 1.5
    static let minRotation: Angle = -maxRotation

    var rotationPattern: RotationPattern
    var whoToTarget: TileTypePred
    var whenToFire: WhenToFire
    var howToFire: HowToFire
    var whatToFire: TileType
    var delayWhenTargetFoundBeforeFire: CGFloat
    var spreadPattern: SpreadPattern

    var rotatesClockwiseWhenContinuously: Bool = false
    var targetState: TargetState = .targetNotFound
    var fireState: FireState = .targetNotFound

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case rotationPattern
        case whoToTarget
        case whenToFire
        case howToFire
        case whatToFire
        case delayWhenTargetFoundBeforeFire
        case spreadPattern
    }

    typealias AsSetting = StructSetting<TurretComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "rotationPattern": RotationPattern.newSetting(),
            "whoToTarget": TileTypePredSetting(),
            "whenToFire": WhenToFire.newSetting(),
            "howToFire": HowToFire.newSetting(),
            "whatToFire": TileTypeSetting(),
            "delayWhenTargetFoundBeforeFire": CGFloatRangeSetting(0...64),
            "spreadPattern": SpreadPattern.newSetting()
        ], optionalFields: [:])
    }
    // endregion
}
