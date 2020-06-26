//
// Created by Jakob Hain on 6/26/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct LifetimeSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}
    static func postTick(world: World) {}

    func tick() {
        if entity.next.dalC != nil {
            incrementLifetime()
        }
    }

    private func incrementLifetime() {
        assert(entity.next.dalC != nil)
        entity.next.dalC!.lifetime += world.settings.fixedDeltaTime
        if entity.next.dalC!.lifetime >= entity.next.dalC!.maxLifetime && entity.world != nil {
            world.remove(entity: entity)
        }
    }
}
