//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MatterSystem: SubCollisionSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    mutating func handleOverlappingCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {}

    mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos, side: Side) {
        if entity.next.matC != nil {
            // We want to include knockback of other tiles at this position.
            // If there are multiple solid tiles (not currently possible) this would be run twice,
            // but that's ok
            let typesAtPosition = world[tilePosition]
            let knockback = typesAtPosition.map { typeAtPosition in world.settings.knockback[typeAtPosition] ?? 0 }.max() ?? 0

            let isAdjacentWithoutKnockback = knockback == 0
            var isJustCollidingWithoutKnockback = false
            switch side {
            case .east:
                isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.x > CGFloat.epsilon
                entity.next.dynC!.velocity.x = min(entity.next.dynC!.velocity.x, -knockback)
            case .north:
                isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.y > CGFloat.epsilon
                entity.next.dynC!.velocity.y = min(entity.next.dynC!.velocity.y, -knockback)
            case .west:
                isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.x < -CGFloat.epsilon
                entity.next.dynC!.velocity.x = max(entity.next.dynC!.velocity.x, knockback)
            case .south:
                isJustCollidingWithoutKnockback = isAdjacentWithoutKnockback && entity.next.dynC!.velocity.y < -CGFloat.epsilon
                entity.next.dynC!.velocity.y = max(entity.next.dynC!.velocity.y, -knockback)
            }
            if isAdjacentWithoutKnockback {
                entity.next.locC!.rotation = Angle.zero
                if isJustCollidingWithoutKnockback {
                    entity.next.dynC!.angularVelocity = Angle.zero.toUnclamped
                }
            }
        }
    }

    mutating func handleCollisionWith(entity otherEntity: Entity) {
        // Only want to be affected by new collisions
        if entity.next.matC != nil && !entity.prev.colC!.overlappingEntities.contains(otherEntity) {
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
                if doesEntityReverseVelocities(entity: otherEntity) {
                    let knockback = world.settings.knockback[otherEntity.type] ?? 0
                    if entity.next.dynC!.velocity.projectedOnto(angle: directionAwayFromOtherEntity) < knockback {
                        entity.next.dynC!.velocity = CGPoint(magnitude: knockback, directionFromOrigin: directionAwayFromOtherEntity)
                    }
                } else {
                    entity.next.dynC!.velocity = CGPoint.zero
                }

                // Currently we don't stop handling collisions because it makes the system too complicated
                // (trying to get A collides with B => B collides with A,
                // where A and B are moving entities which could collide with other earlier entities,
                // is hard)
                // stopHandlingCollisions = true
            }

            if otherEntity.next.matC != nil {
                // We don't want infinite knockback because it could break physics,
                // but 1 / epsilon should be enough to have practically the exact same effects as what's intended to happen
                let matterKnockbackAmount = min(1 / CGFloat.epsilon, otherEntity.next.matC!.mass / entity.next.matC!.mass)
                let matterKnockback = CGPoint(magnitude: matterKnockbackAmount, directionFromOrigin: directionAway)
                entity.next.dynC!.velocity += matterKnockback

                // Currently we don't stop handling collisions because it makes the system too complicated
                // (trying to get A collides with B => B collides with A,
                // where A and B are moving entities which could collide with other earlier entities,
                // is hard)
                // stopHandlingCollisions = true
            }

            if otherEntity.next.dynC != nil {
                // We need to use prev because the other entity might have already been affected by this one
                let dynamicKnockback = otherEntity.prev.dynC!.velocity * otherEntity.next.dynC!.dynamicKnockbackMultiplier
                entity.next.dynC!.velocity += dynamicKnockback
            }
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
        entity.next.matC != nil || entity.world!.settings.knockback[entity.type] != nil
    }

    private func doesEntityReverseVelocities(entity: Entity) -> Bool {
        MatterSystem.isEntitySemiSolid(entity: entity) && entity.next.matC == nil
    }
}
