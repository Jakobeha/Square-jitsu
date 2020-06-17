//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

let EarlyTopLevelSystems: [TopLevelSystem.Type] = [
    CollisionSystem.self,
    NearCollisionSystem.self
]

let TopLevelSystems: [TopLevelSystem.Type] = [
    AINinjaSystem.self,
    // Must be after AINinjaSystem
    NinjaSystem.self,
    ImplicitForcesSystem.self,
    // Must be after ImplicitForcesSystem and NinjaSystem
    MovementSystem.self,
    // Must be after MovementSystem
    CollisionSystem.self,
    // Must be after CollisionSystem
    NearCollisionSystem.self,
    // Must be after CollisionSystem
    GrabSystem.self,
    // Must be after CollisionSystem and GrabSystem
    OverlapSensitiveSystem.self,
    // Must be after CollisionSystem and GrabSystem
    AdjacentSensitiveSystem.self,
    // Must be after CollisionSystem and GrabSystem
    CreateOnCollideSystem.self,
    // Must be after CollisionSystem
    TurretSystem.self,
    // Must be after CollisionSystem
    DamageSystem.self,
    // Must be last
    LoadPositionSystem.self
]

/// System which runs on tick, not interleaved with other top-level systems
protocol TopLevelSystem: System {
    static func preTick(world: World)

    static func postTick(world: World)

    mutating func tick()
}

extension TopLevelSystem {
    static func tick(world: World) {
        preTick(world: world)
        for entity in world.entities {
            tick(entity: entity)
        }
        postTick(world: world)
    }

    static func tick(entity: Entity) {
        var system = Self(entity: entity)
        system.tick()
    }
}
