//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct LoadPositionSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    func tick() {
        if entity.prev.locC != nil {
            world.load(pos: entity.prev.locC!.position)
        }
    }
}
