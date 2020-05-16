//
// Created by Jakob Hain on 5/15/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretComponent {
    enum RotationPattern {
        case neverRotate
        case rotateAtSpeed(speed: UnclampedAngle)
        case rotateInstantly
    }

    enum WhenToFire {
        case alwaysFire
        case fireOnSeek
    }

    enum HowToFire {
        case consistent(projectileSpeed: CGFloat, delay: CGFloat)
        case burst(projectileSpeed: CGFloat, delayInBurst: CGFloat, delayBetweenBursts: CGFloat)
        /// Always fire (e.g. with a laser)
        case continuous
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
    }

    let rotationPattern: RotationPattern
    let whoToTarget: TileTypePred
    let whenToFire: WhenToFire
    let howToFire: HowToFire
    let whatToFire: TileType
    let delayWhenTargetFoundBeforeFire: CGFloat

    let targetState: TargetState
    let fireState: FireState
}
