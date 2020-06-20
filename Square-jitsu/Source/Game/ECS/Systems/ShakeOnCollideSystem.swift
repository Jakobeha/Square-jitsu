//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ShakeOnCollideSystem: EarlyTopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tickOnSpawn() {
        if isEntityColliding {
            shakeIfNecessary()
        }
    }

    func tick() {
        if didEntityJustStartColliding {
            shakeIfNecessary()
        }
    }

    private func shakeIfNecessary() {
        if let shake = world.settings.amountScreenShakesWhenEntityCollides[entity.type] {
            world.playerCamera.add(shake: shake)
        }
    }

    private var didEntityJustStartColliding: Bool {
        ShakeOnCollideSystem.areComponentsColliding(components: entity.next) &&
        !ShakeOnCollideSystem.areComponentsColliding(components: entity.prev)
    }

    private var isEntityColliding: Bool {
        ShakeOnCollideSystem.areComponentsColliding(components: entity.next)
    }

    private static func areComponentsColliding(components: Entity.Components) -> Bool {
        components.colC != nil &&
        (!components.colC!.adjacentSides.isEmpty || !components.colC!.overlappingEntities.isEmpty)
    }
}
