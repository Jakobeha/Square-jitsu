//
// Created by Jakob Hain on 6/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

let EarlyTopLevelSystems: [EarlyTopLevelSystem.Type] = [
    CollisionSystem.self,
    NearCollisionSystem.self,
    ShakeOnCollideSystem.self
]

protocol EarlyTopLevelSystem: TopLevelSystem {
    /// Called when an entity first spawns
    mutating func tickOnSpawn()
}

extension EarlyTopLevelSystem {
    static func tickOnSpawn(entity: Entity) {
        var system = Self(entity: entity)
        system.tickOnSpawn()
    }
}