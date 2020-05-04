//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol System {
    static func tick(entity: Entity)
}

extension System {
    static func tick(world: World) {
        for entity in world.entities {
            tick(entity: entity)
        }
    }
}
