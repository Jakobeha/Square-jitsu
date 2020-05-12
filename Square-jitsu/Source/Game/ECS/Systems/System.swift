//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// The system itself is the class.
/// We use a "System" instance for each entity to reduce boilerplate
protocol System {
    var entity: Entity { get }

    init(entity: Entity)

    static func preTick(world: World)

    static func postTick(world: World)

    mutating func tick()
}

extension System {
    static func tick(world: World) {
        preTick(world: world)
        for entity in world.entities {
            var system = Self(entity: entity)
            system.tick()
        }
        postTick(world: world)
    }

    var world: World { entity.world! }
}
