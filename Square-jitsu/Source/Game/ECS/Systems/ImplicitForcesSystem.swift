//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImplicitForcesSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.imfC != nil && shouldApplyForces {
            if entity.prev.colC != nil {
                if entity.prev.colC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let solidFrictionMultiplier = 1 - entity.prev.imfC!.solidFriction
                    if entity.prev.colC!.adjacentSides.hasVertical {
                        entity.next.dynC!.velocity.x *= solidFrictionMultiplier
                    }
                    if entity.prev.colC!.adjacentSides.hasHorizontal {
                        entity.next.dynC!.velocity.y *= solidFrictionMultiplier
                    }
                }
                if entity.prev.colC!.overlappingTypes.contains(layer: TileLayer.iceSolid) && !entity.prev.colC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let minSpeedOnIce = entity.prev.imfC!.minSpeedOnIce
                    if entity.prev.colC!.adjacentSides.hasVertical && !entity.prev.colC!.adjacentSides.hasHorizontal {
                        if entity.next.dynC!.velocity.x.magnitude < minSpeedOnIce {
                            entity.next.dynC!.velocity.x = entity.next.dynC!.velocity.x < 0 ? -minSpeedOnIce : minSpeedOnIce
                        }
                    }
                    if entity.prev.colC!.adjacentSides.hasHorizontal && !entity.prev.colC!.adjacentSides.hasVertical {
                        if entity.next.dynC!.velocity.y.magnitude < minSpeedOnIce {
                            entity.next.dynC!.velocity.y = entity.next.dynC!.velocity.y < 0 ? -minSpeedOnIce : minSpeedOnIce
                        }
                    }
                }
            }
            if isEntityInAir {
                entity.next.dynC!.velocity.y -= entity.prev.imfC!.gravity * world.settings.fixedDeltaTime
                entity.next.dynC!.angularVelocity *= 1 - entity.next.imfC!.aerialAngularFriction
            }
        }
    }

    private var shouldApplyForces: Bool {
        !(entity.prev.graC?.grabState.isGrabbed ?? false)
    }

    private var isEntityInAir: Bool {
        entity.prev.colC == nil || !entity.prev.colC!.hasAdjacents
    }
}
