//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.turC != nil {
            updateTurret()
        }
    }

    private func updateTurret() {
        entity.next.turC!.targetState = nextTargetState()
        rotateTurretToTarget()
        entity.next.turC!.fireState = nextFireState()
    }

    private func nextTargetState() -> TurretComponent.TargetState {
        let whoToTarget = entity.next.turC!.whoToTarget
        for otherEntity in world.entities {
            if whoToTarget.contains(otherEntity.type) && isEntityVisibleToTurret(otherEntity: otherEntity) {
                if isEntityInLineOfFire(otherEntity: otherEntity) {
                    return .targetInLineOfFire(entity: EntityRef(otherEntity))
                } else {
                    return .targetFoundSeeking(entity: EntityRef(otherEntity))
                }
            }
        }
        return .targetNotFound
    }

    private func isEntityVisibleToTurret(otherEntity: Entity) -> Bool {
        let lineFromTurretToEntity = Line(start: entity.next.locC!.position, end: otherEntity.next.locC!.position)
        if lineFromTurretToEntity.length > TurretComponent.turretVisibilityRadius {
            return false
        }

        let tilePositionsFromTurretToEntity = lineFromTurretToEntity.capsuleCastTilePositions(capsuleRadius: 0)
        for tilePositionFromTurretToEntity in tilePositionsFromTurretToEntity {
            let tileTypesAtPosition = world[tilePositionFromTurretToEntity]
            for tileTypeFromTurretToEntity in tileTypesAtPosition {
                if tileTypeFromTurretToEntity.isSolid {
                    return false
                }
            }
        }

        return true
    }

    private func isEntityInLineOfFire(otherEntity: Entity) -> Bool {
        switch entity.next.turC!.rotationPattern {
        case .neverRotate:
            fatalError("illegal state - isEntityInLineOfFire called when turret doesn't rotate")
        case .rotateAtSpeed(let speed):
            if otherEntity.next.locC != nil {
                let directionToOtherEntity = (otherEntity.next.locC!.position - entity.next.locC!.position).directionFromOrigin
                let currentDirection = entity.next.locC!.rotation
                let directionOffset = directionToOtherEntity - currentDirection
                let deltaRotation = speed * world.settings.fixedDeltaTime
                return directionOffset.absolute.toUnclamped < deltaRotation
            } else {
                return false
            }
        case .rotateInstantly:
            return true
        }
    }

    private func rotateTurretToTarget() {
        switch entity.next.turC!.rotationPattern {
        case .neverRotate:
            break
        case .rotateAtSpeed(let speed):
            if let directionToTarget = directionToTarget {
                let currentDirection = entity.prev.locC!.rotation
                let directionOffset = directionToTarget - currentDirection
                let deltaRotation = speed * world.settings.fixedDeltaTime
                if directionOffset.absolute.toUnclamped < deltaRotation {
                    // Will rotate to target instantly
                    entity.next.locC!.rotation = directionToTarget
                } else if directionOffset.isCounterClockwise {
                    entity.next.locC!.rotation += deltaRotation
                } else {
                    entity.next.locC!.rotation -= deltaRotation
                }
            }
        case .rotateInstantly:
            if let directionToTarget = directionToTarget {
                entity.next.locC!.rotation = directionToTarget
            }
        }
    }

    private var directionToTarget: Angle? {
        if let target = entity.next.turC!.targetState.target?.deref {
            if target.next.locC == nil {
                Logger.warnSettingsAreInvalid("turret \(entity) is trying to target \(target) by rotating to face it, but it can't because the target doesn't have a location")
            }
            return (target.next.locC!.position - entity.next.locC!.position).directionFromOrigin
        } else {
            return nil
        }
    }

    private func nextFireState() -> TurretComponent.FireState {
        switch entity.prev.turC!.fireState {
        case .targetNotFound:
            if shouldTurretFire {
                return stateWhenJustFoundTarget
            } else {
                return .targetNotFound
            }
        case .targetFoundNeedToCharge(let timeUntilFire):
            if shouldTurretFire {
                let nextTimeUntilFire = timeUntilFire - world.settings.fixedDeltaTime
                if nextTimeUntilFire > 0 {
                    return .targetFoundNeedToCharge(timeUntilFire: nextTimeUntilFire)
                } else {
                    fireProjectile()
                    return stateAfterFire
                }
            } else {
                return stateWhenLostTarget(prevTimeUntilFire: timeUntilFire)
            }
        case .didFireReloading(let timeUntilFire):
            if shouldTurretFire {
                let nextTimeUntilFire = timeUntilFire - world.settings.fixedDeltaTime
                if nextTimeUntilFire > 0 {
                    return .didFireReloading(timeUntilFire: nextTimeUntilFire)
                } else {
                    fireProjectile()
                    return stateAfterFire
                }
            } else {
                return stateWhenLostTarget(prevTimeUntilFire: timeUntilFire)
            }
        case .didFireInBurstReloading(let timeUntilFire, let numShotsLeftInBurstAfterThis):
            if shouldTurretFire {
                let nextTimeUntilFire = timeUntilFire - world.settings.fixedDeltaTime
                if nextTimeUntilFire > 0 {
                    return .didFireInBurstReloading(timeUntilFire: nextTimeUntilFire, numShotsLeftInBurstAfterThis: numShotsLeftInBurstAfterThis)
                } else {
                    fireProjectile()
                    return stateAfterBurstFire(numShotsLeftInBurstAfterThis: numShotsLeftInBurstAfterThis)
                }
            } else {
                return stateWhenLostTarget(prevTimeUntilFire: timeUntilFire)
            }
        case .isFiringContinuous:
            if shouldTurretFire {
                return .isFiringContinuous
            } else {
                return stateWhenLostTarget(prevTimeUntilFire: 0)
            }
        }
    }

    var shouldTurretFire: Bool {
        switch entity.next.turC!.whenToFire {
        case .alwaysFire:
            return true
        case .fireOnSeek:
            return entity.next.turC!.targetState.target != nil
        }
    }

    private var stateWhenJustFoundTarget: TurretComponent.FireState {
        .targetFoundNeedToCharge(timeUntilFire: entity.next.turC!.delayWhenTargetFoundBeforeFire)
    }

    private func stateWhenLostTarget(prevTimeUntilFire: CGFloat) -> TurretComponent.FireState {
        let nextTimeUntilFire = prevTimeUntilFire + world.settings.fixedDeltaTime
        if nextTimeUntilFire > entity.next.turC!.delayWhenTargetFoundBeforeFire {
            return .targetNotFound
        } else {
            return .targetFoundNeedToCharge(timeUntilFire: nextTimeUntilFire)
        }
    }

    private var stateAfterFire: TurretComponent.FireState {
        switch entity.prev.turC!.howToFire {
        case .consistent(projectileSpeed: _, let delay):
            return .didFireReloading(timeUntilFire: delay)
        case .burst(projectileSpeed: _, delayBetweenBursts: _, let numShotsInBurst, let delayInBurst):
            return .didFireInBurstReloading(timeUntilFire: delayInBurst, numShotsLeftInBurstAfterThis: numShotsInBurst - 2)
        case .continuous:
            return .isFiringContinuous
        }
    }

    private func stateAfterBurstFire(numShotsLeftInBurstAfterThis: Int) -> TurretComponent.FireState {
        switch entity.prev.turC!.howToFire {
        case .burst(projectileSpeed: _, let delayBetweenBursts, let numShotsInBurst, let delayInBurst):
            if numShotsLeftInBurstAfterThis == 0 {
                return .didFireInBurstReloading(timeUntilFire: delayBetweenBursts, numShotsLeftInBurstAfterThis: numShotsInBurst - 1)
            } else {
                return .didFireInBurstReloading(timeUntilFire: delayInBurst, numShotsLeftInBurstAfterThis: numShotsLeftInBurstAfterThis - 1)
            }
        default:
            fatalError("illegal state - stateAfterBurstFire called on turret which doesn't do burst fire")
        }
    }

    private func fireProjectile() {
        let projectileDirection = entity.next.locC!.rotation
        let projectile = Entity.new(type: projectileType, pos: entity.next.locC!.position, world: world)
        projectile.next.toxC?.safeEntities.insert(EntityRef(entity))
        projectile.next.locC!.rotation = projectileDirection
        if let projectileSpeed = entity.next.turC!.howToFire.projectileSpeed {
            projectile.next.dynC!.velocity = CGPoint(magnitude: projectileSpeed, directionFromOrigin: projectileDirection)
        }
    }

    private var projectileType: TileType {
        TileType(bigType: .projectile, smallType: entity.type.smallType)
    }
}
