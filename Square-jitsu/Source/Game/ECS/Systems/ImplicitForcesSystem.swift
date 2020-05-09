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

    func tick() {
        if entity.prev.phyC != nil {
            if entity.prev.phyC!.overlappingTypes.contains(bigType: TileBigType.solid) {
                if entity.prev.phyC!.adjacentSides.hasHorizontal {
                    entity.next.dynC!.velocity.x *= 1 - entity.prev.phyC!.solidFriction
                }
                if entity.prev.phyC!.adjacentSides.hasVertical {
                    entity.next.dynC!.velocity.y *= 1 - entity.prev.phyC!.solidFriction
                }
            }
        }
        if entity.prev.imfC != nil {
            if shouldApplyGravity {
                entity.next.dynC!.velocity.y -= entity.prev.imfC!.gravity * world.settings.fixedDeltaTime
            }
            entity.next.dynC!.angularVelocity *= 1 - entity.next.imfC!.aerialAngularFriction
        }
    }

    private var shouldApplyGravity: Bool {
        entity.prev.phyC == nil || !entity.prev.phyC!.hasAdjacents
    }
}
