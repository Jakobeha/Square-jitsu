//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImplicitForcesSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.imfC != nil && shouldApplyForces {
            if entity.prev.phyC != nil {
                if entity.prev.phyC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let solidFrictionMultiplier = 1 - entity.prev.imfC!.solidFriction
                    if entity.prev.phyC!.adjacentSides.hasVertical {
                        entity.next.dynC!.velocity.x *= solidFrictionMultiplier
                    }
                    if entity.prev.phyC!.adjacentSides.hasHorizontal {
                        entity.next.dynC!.velocity.y *= solidFrictionMultiplier
                    }
                }
                if entity.prev.phyC!.overlappingTypes.contains(layer: TileLayer.iceSolid) && !entity.prev.phyC!.overlappingTypes.contains(layer: TileLayer.solid) {
                    let minSpeedOnIce = entity.prev.imfC!.minSpeedOnIce
                    if entity.prev.phyC!.adjacentSides.hasVertical && !entity.prev.phyC!.adjacentSides.hasHorizontal {
                        if entity.next.dynC!.velocity.x.magnitude < minSpeedOnIce {
                            entity.next.dynC!.velocity.x = entity.next.dynC!.velocity.x < 0 ? -minSpeedOnIce : minSpeedOnIce
                        }
                    }
                    if entity.prev.phyC!.adjacentSides.hasHorizontal && !entity.prev.phyC!.adjacentSides.hasVertical {
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
        entity.prev.phyC == nil || !entity.prev.phyC!.hasAdjacents
    }
}
