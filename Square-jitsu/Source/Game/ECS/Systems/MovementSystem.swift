//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MovementSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    func tick() {
        if entity.prev.dynC != nil {
            entity.next.locC!.position += entity.prev.dynC!.velocity * world.settings.fixedDeltaTime
            entity.next.locC!.rotation += entity.prev.dynC!.angularVelocity * world.settings.fixedDeltaTime
        }
    }
}
