//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class MovementSystem: System {
    static func tick(entity: Entity) {
        if (entity.prev.phyC != nil) {
            if (entity.prev.phyC!.adjacentSides.hasHorizontal) {
                entity.next.dynC!.velocity.x *= 1 - entity.prev.phyC!.friction
            }
            if (entity.prev.phyC!.adjacentSides.hasVertical) {
                entity.next.dynC!.velocity.y *= 1 - entity.prev.phyC!.friction
            }
        }
        if (entity.prev.dynC != nil) {
            if (shouldApplyGravityTo(entity: entity)) {
                entity.next.dynC!.velocity.y -= entity.prev.dynC!.gravity * entity.world!.settings.fixedDeltaTime
            }
            entity.next.locC!.position += entity.prev.dynC!.velocity * entity.world!.settings.fixedDeltaTime
            entity.next.locC!.rotation += entity.prev.dynC!.angularVelocity * entity.world!.settings.fixedDeltaTime
        }
    }

    private static func shouldApplyGravityTo(entity: Entity) -> Bool {
        entity.prev.phyC == nil || !entity.prev.phyC!.hasAdjacents
    }
}
