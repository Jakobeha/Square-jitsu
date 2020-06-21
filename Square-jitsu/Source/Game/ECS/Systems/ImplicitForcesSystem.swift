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
        if entity.next.imfC != nil && shouldApplyForces {
            if entity.next.colC != nil {
                if entity.next.colC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let solidFrictionMultiplier = 1 - entity.next.imfC!.solidFriction
                    if entity.next.colC!.adjacentSides.hasVertical {
                        entity.next.dynC!.velocity.x *= solidFrictionMultiplier
                    }
                    if entity.next.colC!.adjacentSides.hasHorizontal {
                        entity.next.dynC!.velocity.y *= solidFrictionMultiplier
                    }
                }
                if entity.next.colC!.overlappingTypes.contains(layer: TileLayer.iceSolid) && !entity.next.colC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let minSpeedOnIce = entity.next.imfC!.minSpeedOnIce
                    if entity.next.colC!.adjacentSides.hasVertical && !entity.next.colC!.adjacentSides.hasHorizontal {
                        if entity.next.dynC!.velocity.x.magnitude < minSpeedOnIce {
                            entity.next.dynC!.velocity.x = entity.next.dynC!.velocity.x < 0 ? -minSpeedOnIce : minSpeedOnIce
                        }
                    }
                    if entity.next.colC!.adjacentSides.hasHorizontal && !entity.next.colC!.adjacentSides.hasVertical {
                        if entity.next.dynC!.velocity.y.magnitude < minSpeedOnIce {
                            entity.next.dynC!.velocity.y = entity.next.dynC!.velocity.y < 0 ? -minSpeedOnIce : minSpeedOnIce
                        }
                    }
                }
            }
            if isEntityInAir {
                entity.next.dynC!.velocity.y -= entity.next.imfC!.gravity * world.settings.fixedDeltaTime
                entity.next.dynC!.angularVelocity *= 1 - entity.next.imfC!.aerialAngularFriction
            }
        }
    }

    private var shouldApplyForces: Bool {
        !(entity.next.graC?.grabState.isGrabbed ?? false)
    }

    private var isEntityInAir: Bool {
        entity.next.colC == nil || !entity.next.colC!.hasAdjacents
    }
}
