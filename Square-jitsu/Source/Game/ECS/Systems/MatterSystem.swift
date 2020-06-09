//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MatterSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    mutating func tick() {
        if entity.next.matC != nil {
            handleTileCollisions()
            handleEntityCollisions()
        }
    }

    private mutating func handleTileCollisions() {
        for (side, tilePositions) in newAdjacentTilePositions {
            for tilePosition in tilePositions {
                let tileTypes = world[tilePosition]
                for tileType in tileTypes {
                    handleSolidCollisionWith(tileType: tileType, tilePosition: tilePosition, side: side)
                }
            }
        }
    }

    private mutating func handleEntityCollisions() {
        for entity in newOverlappingEntities {
            if handlesCollisionsWith(entity: entity) {
                handleCollisionWith(entity: entity)
                if stopEntityCollisions {
                    break
                }
            }
        }
    }

    private var newAdjacentTilePositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        DenseEnumMap { side in
            entity.next.colC!.adjacentPositions[side].subtracting(entity.prev.colC!.adjacentPositions[side])
        }
    }

    private var newOverlappingTilePositions: [WorldTilePos] {
        entity.next.colC!.overlappingPositions.subtracting(entity.prev.colC!.overlappingPositions)
    }

    private var newOverlappingEntities: [Entity] {
        entity.next.colC!.overlappingEntities.subtracting(entity.prev.colC!.overlappingEntities)
    }

    // Can get changed to true
    var stopEntityCollisions: Bool = false

    private mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos, side: Side) {
        let radiusSum = entity.next.locC!.radius + 0.5
        let knockback = world.settings.knockback[tileType] ?? 0
        let isAdjacentWithoutKnockback = knockback == 0
        var isJustCollidingWithoutKnockback = false
        switch side {
        case .east:
            let xBarrier = tilePosition.cgPoint.x - radiusSum
            entity.next.locC!.position.x = min(entity.next.locC!.position.x, xBarrier)
            isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.x > CGFloat.epsilon
            entity.next.dynC!.velocity.x = min(entity.next.dynC!.velocity.x, -knockback)
        case .north:
            let yBarrier = tilePosition.cgPoint.y - radiusSum
            entity.next.locC!.position.y = min(entity.next.locC!.position.y, yBarrier)
            isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.y > CGFloat.epsilon
            entity.next.dynC!.velocity.y = min(entity.next.dynC!.velocity.y, -knockback)
        case .west:
            let xBarrier = tilePosition.cgPoint.x + radiusSum
            entity.next.locC!.position.x = max(entity.next.locC!.position.x, xBarrier)
            isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.x < -CGFloat.epsilon
            entity.next.dynC!.velocity.x = max(entity.next.dynC!.velocity.x, knockback)
        case .south:
            let yBarrier = tilePosition.cgPoint.y - radiusSum
            entity.next.locC!.position.y = max(entity.next.locC!.position.y, yBarrier)
            isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.y < -CGFloat.epsilon
            entity.next.dynC!.velocity.y = max(entity.next.dynC!.velocity.y, -knockback)
        }
        if isAdjacentWithoutKnockback {
            entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
            if isJustCollidingWithoutKnockback {
                entity.next.dynC!.angularVelocity = Angle.zero.toUnclamped
            }
        }
    }

    private func handlesCollisionsWith(entity otherEntity: Entity) -> Bool {
        otherEntity.next.locC != nil || otherEntity.next.lilC != nil
    }

    private mutating func handleCollisionWith(entity otherEntity: Entity) {
        assert(handlesCollisionsWith(entity: otherEntity))
        let directionAwayFromOtherEntity = getDirectionAwayFrom(entity: otherEntity)
        // We use the opposite direction of the entity's velocity,
        // as long as it actually goes away from the other entity,
        // because it's more predictable
        let directionAway =
                entity.next.dynC!.velocity.magnitude > CGFloat.epsilon &&
                ((entity.next.dynC!.velocity.directionFromOrigin + Angle.straight.toUnclamped) - directionAwayFromOtherEntity).isAbsoluteSmallerThan(angle: Angle.right) ?
                entity.next.dynC!.velocity.directionFromOrigin + Angle.straight.toUnclamped :
                directionAwayFromOtherEntity

        if MatterSystem.isEntitySemiSolid(entity: otherEntity) {
            let otherEntityClosestPoint = getClosestPointOn(entity: otherEntity)
            let radiusSum = entity.next.locC!.radius + MatterSystem.getRadiusOrThicknessOf(entity: otherEntity)
            let positionOffset = CGPoint(magnitude: radiusSum, directionFromOrigin: directionAwayFromOtherEntity)
            entity.next.locC!.position = otherEntityClosestPoint + positionOffset
            stopEntityCollisions = true
        }

        // The condition never actually happens yet, not sure if this is what we want...
        if MatterSystem.doesEntityNullifyVelocities(entity: otherEntity) {
            entity.next.dynC!.velocity = entity.next.dynC!.velocity.projectedPointOnto(angle: directionAway)
            entity.next.dynC!.angularVelocity = Angle.zero.toUnclamped
            stopEntityCollisions = true
        }

        if otherEntity.next.matC != nil {
            // We don't want infinite knockback because it could break physics,
            // but 1 / epsilon should be enough to have practically the exact same effects as what's intended to happen
            let matterKnockbackAmount = max(1 / CGFloat.epsilon, otherEntity.next.matC!.mass / entity.next.matC!.mass)
            let matterKnockback = CGPoint(magnitude: matterKnockbackAmount, directionFromOrigin: directionAway)
            entity.next.dynC!.velocity += matterKnockback
            stopEntityCollisions = true
        }

        let staticKnockbackAmount = world.settings.knockback[otherEntity.type] ?? 0
        let staticKnockback = CGPoint(magnitude: staticKnockbackAmount, directionFromOrigin: directionAway)
        entity.next.dynC!.velocity += staticKnockback

        if otherEntity.next.dynC != nil {
            // We need to use prev because the other entity might have already been affected by this one
            let dynamicKnockback = otherEntity.prev.dynC!.velocity * otherEntity.next.dynC!.dynamicKnockbackMultiplier
            entity.next.dynC!.velocity += dynamicKnockback
        }
    }

    private func getDirectionAwayFrom(entity otherEntity: Entity) -> Angle {
        if otherEntity.next.locC != nil {
            return otherEntity.next.locC!.position.getDirectionTo(point: entity.next.locC!.position)
        } else if otherEntity.next.lilC != nil {
            return otherEntity.next.lilC!.position.getDirectionTo(point: entity.next.locC!.position)
        } else {
            fatalError("illegal state - getDirectionOf called on entity which we don't handle matter collisions with because it doesn't have a usable location component")
        }
    }

    private func getClosestPointOn(entity otherEntity: Entity) -> CGPoint {
        if otherEntity.next.locC != nil {
            return entity.next.locC!.position
        } else if otherEntity.next.lilC != nil {
            return otherEntity.next.lilC!.position.getClosestPointTo(point: entity.next.locC!.position)
        } else {
            fatalError("illegal state - getDirectionOf called on entity which we don't handle matter collisions with because it doesn't have a usable location component")
        }
    }

    private static func getRadiusOrThicknessOf(entity: Entity) -> CGFloat {
        if entity.next.locC != nil {
            return entity.next.locC!.radius
        } else if entity.next.lilC != nil {
            return entity.next.lilC!.thickness
        } else {
            fatalError("illegal state - getRadiusOrThicknessOf called on entity which we don't handle matter collisions with because it doesn't have a usable location component")
        }
    }

    private static func isEntitySemiSolid(entity: Entity) -> Bool {
        !(entity.next.docC?.destroyOnEntityCollision ?? false)
    }

    private static func doesEntityNullifyVelocities(entity: Entity) -> Bool {
        isEntitySemiSolid(entity: entity) && entity.next.matC == nil
    }
}
