//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class LocationSystem: System {
    static func tick(entity: Entity) {
        if (entity.prev.locC != nil) {
            entity.world!.load(pos: entity.prev.locC!.position)
        }
    }
}
