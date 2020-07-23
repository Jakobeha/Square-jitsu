//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.next.turC != nil {
            updateTurret()
        }
    }

    private func updateTurret() {
        entity.next.turC!.targetState = nextTargetState()
        rotateTurret()
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
        let lineFromTurretToEntity = LineSegment(start: entity.next.locC!.position, end: otherEntity.next.locC!.position)
        if lineFromTurretToEntity.length > TurretComponent.turretVisibilityRadius {
            return false
        }

        let tilePositionsFromTurretToEntity = lineFromTurretToEntity.capsuleCastTilePositions(capsuleRadius: 0)
        for tilePositionFromTurretToEntity in tilePositionsFromTurretToEntity {
            let tileTypesAtPosition = world[tilePositionFromTurretToEntity]
            for tileTypeFromTurretToEntity in tileTypesAtPosition {
                if tileTypeFromTurretToEntity.blocksVision {
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
        case .rotateContinuously(let speed):
            return isEntityInLineOfFire(otherEntity: otherEntity, rotationSpeed: speed)
        case .rotateToTarget(let speed):
            return isEntityInLineOfFire(otherEntity: otherEntity, rotationSpeed: speed)
        case .rotateToTargetInstantly:
            return true
        }
    }

    private func isEntityInLineOfFire(otherEntity: Entity, rotationSpeed: UnclampedAngle) -> Bool {
        if otherEntity.next.locC != nil {
            let directionToOtherEntity = (otherEntity.next.locC!.position - entity.next.locC!.position).directionFromOrigin
            let currentDirection = entity.next.locC!.rotation
            let directionOffset = directionToOtherEntity - currentDirection
            let deltaRotation = rotationSpeed * world.settings.fixedDeltaTime
            return directionOffset.isAbsoluteSmallerThan(angle: deltaRotation)
        } else {
            return false
        }
    }

    private func rotateTurret() {
        switch entity.next.turC!.rotationPattern {
        case .neverRotate:
            break
        case .rotateContinuously(let speed):
            let deltaRotation = speed * world.settings.fixedDeltaTime
            entity.next.locC!.rotation += deltaRotation
        case .rotateToTarget(let speed):
            if let directionToTarget = directionToTarget {
                let currentDirection = entity.prev.locC!.rotation
                let directionOffset = directionToTarget - currentDirection
                let deltaRotation = speed * world.settings.fixedDeltaTime
                if directionOffset.isAbsoluteSmallerThan(angle: deltaRotation) {
                    // Will rotate to target instantly
                    entity.next.locC!.rotation = directionToTarget
                } else if directionOffset.isCounterClockwise {
                    entity.next.locC!.rotation += deltaRotation
                } else {
                    entity.next.locC!.rotation -= deltaRotation
                }
            }
        case .rotateToTargetInstantly:
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
        switch entity.next.turC!.fireState {
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
                    fire()
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
                    fire()
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
                    fire()
                    return stateAfterBurstFire(numShotsLeftInBurstAfterThis: numShotsLeftInBurstAfterThis)
                }
            } else {
                return stateWhenLostTarget(prevTimeUntilFire: timeUntilFire)
            }
        case .isFiringContinuous(let projectiles):
            if shouldTurretFire {
                keepFiringContinuousProjectiles(projectiles: projectiles)
                return .isFiringContinuous(projectiles: projectiles)
            } else {
                destroyContinuousProjectiles(projectiles: projectiles)
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
        switch entity.next.turC!.howToFire {
        case .consistent(projectileSpeed: _, let delay):
            return .didFireReloading(timeUntilFire: delay)
        case .burst(projectileSpeed: _, delayBetweenBursts: _, let numShotsInBurst, let delayInBurst):
            return .didFireInBurstReloading(timeUntilFire: delayInBurst, numShotsLeftInBurstAfterThis: numShotsInBurst - 2)
        case .continuous:
            assert(entity.next.turC!.fireState.isContinuous, "illegal state - stateAfterFire called on continuous firing-turret, but turret's firing state isn't continuous")
            return entity.next.turC!.fireState
        }
    }

    private func stateAfterBurstFire(numShotsLeftInBurstAfterThis: Int) -> TurretComponent.FireState {
        switch entity.next.turC!.howToFire {
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

    private func fire() {
        let projectiles = fireProjectilesInitially()

        if entity.next.turC!.howToFire.isContinuous {
            entity.next.turC!.fireState = .isFiringContinuous(projectiles: projectiles)
        }
    }

    private func fireProjectilesInitially() -> [(projectileRef: EntityRef, directionOffset: Angle)] {
        switch entity.next.turC!.spreadPattern {
        case .fireStraight:
            return [fireProjectile(directionOffset: Angle.zero)]
        case .fireAround(let totalNumProjectiles):
            return (0..<totalNumProjectiles).map { projectileIndex in
                let directionOffset = Angle(UnclampedAngle.circle * CGFloat(projectileIndex) / CGFloat(totalNumProjectiles))
                return fireProjectile(directionOffset: directionOffset)
            }
        }
    }

    private func fireProjectile(directionOffset: Angle) -> (projectileRef: EntityRef, directionOffset: Angle) {
        let projectile = Entity.spawn(type: entity.next.turC!.whatToFire, world: world) { projectileComponents in
            self.configureProjectile(components: &projectileComponents, directionOffset: directionOffset)
        }
        return (projectileRef: EntityRef(projectile), directionOffset: directionOffset)
    }

    private func keepFiringContinuousProjectiles(projectiles: [(projectileRef: EntityRef, directionOffset: Angle)]) {
        for (projectileRef, directionOffset) in projectiles {
            if let projectile = projectileRef.deref {
                configureProjectile(components: &projectile.next, directionOffset: directionOffset)
            }
        }
    }

    private func destroyContinuousProjectiles(projectiles: [(projectileRef: EntityRef, directionOffset: Angle)]) {
        for (projectileRef, directionOffset: _) in projectiles {
            if let projectile = projectileRef.deref {
               world.remove(entity: projectile)
            }
        }
    }

    private var projectileType: TileType {
        TileType(bigType: .projectile, smallType: entity.type.smallType)
    }

    func configureProjectile(components projectileComponents: inout Entity.Components, directionOffset: Angle) {
        let direction = entity.next.locC!.rotation + directionOffset.toUnclamped

        if projectileComponents.locC != nil {
            assert(!entity.next.turC!.howToFire.isContinuous, "turret can't continuously fire tile with point location (locC)")
            projectileComponents.locC!.position = entity.next.locC!.position
            projectileComponents.locC!.rotation = direction
        } else if projectileComponents.lilC != nil {
            assert(entity.next.turC!.howToFire.isContinuous, "in order to fire tile with line location (lilC), turret must fire continuously")
            let projectileEndTiles = entity.next.turC!.howToFire.continuousProjectileEndTiles

            let projectileRay = Ray(start: entity.next.locC!.position, direction: direction)
            let projectileEndHit = world.cast(
                ray: projectileRay,
                maxDistance: TurretComponent.maxLaserDistance,
                hitPredicate: projectileEndTiles.contains
            )
            if let projectileEndHit = projectileEndHit {
                projectileComponents.lilC!.endEndpointHit = projectileEndHit
                let projectileEndPosition = projectileEndHit.hitPoint
                projectileComponents.lilC!.position = LineSegment(start: projectileRay.start, end: projectileEndPosition)
            } else {
                projectileComponents.lilC!.position = projectileRay.cutoffAt(distance: TurretComponent.maxLaserDistance)
            }
        }

        projectileComponents.docC?.ignoredEntities.insert(EntityRef(entity))

        projectileComponents.toxC?.safeEntities.insert(EntityRef(entity))

        if let projectileSpeed = entity.next.turC!.howToFire.projectileSpeed {
            projectileComponents.dynC!.velocity = CGPoint(magnitude: projectileSpeed, directionFromOrigin: direction)
        }
    }
}
