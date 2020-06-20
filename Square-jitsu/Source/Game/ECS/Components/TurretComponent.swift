//
// Created by Jakob Hain on 5/15/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretComponent: SingleSettingCodable, Codable {
    enum RotationPattern: AutoCodable, SingleSettingCodable {
        case neverRotate
        case rotateAtSpeed(speed: UnclampedAngle)
        case rotateInstantly

        // region encoding and decoding
        typealias AsSetting = ComplexEnumSetting<RotationPattern>

        static func newSetting() -> AsSetting {
            ComplexEnumSetting(cases: [
                "neverRotate": [:],
                "rotateAtSpeed": [
                    "speed": UnclampedAngleSetting()
                ],
                "rotateInstantly": [:]
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
        /// Always fire (e.g. with a laser)
        case continuous

        var projectileSpeed: CGFloat? {
            switch self {
            case .consistent(let projectileSpeed, delay: _):
                return projectileSpeed
            case .burst(let projectileSpeed, delayBetweenBursts: _, numShotsInBurst: _, delayInBurst: _):
                return projectileSpeed
            case .continuous:
                return nil
            }
        }

        var isContinuous: Bool {
            switch self {
            case .continuous:
                return true
            default:
                return false
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
                "continuous": [:]
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
        case isFiringContinuous(projectile: EntityRef)

        var isContinuous: Bool {
            switch self {
            case .isFiringContinuous(projectile: _):
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
    }

    typealias AsSetting = StructSetting<TurretComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "rotationPattern": RotationPattern.newSetting(),
            "whoToTarget": TileTypePredSetting(),
            "whenToFire": WhenToFire.newSetting(),
            "howToFire": HowToFire.newSetting(),
            "whatToFire": TileTypeSetting(),
            "delayWhenTargetFoundBeforeFire": CGFloatRangeSetting(0...64)
        ], optionalFields: [:])
    }
    // endregion
}
