//
// Created by Jakob Hain on 6/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

let SubCollisionSystems: [SubCollisionSystem.Type] = [
    DontClipSystem.self,
    MatterSystem.self,
    RicochetSystem.self
]

/// System which runs immediately on collision
protocol SubCollisionSystem: System {
    mutating func handleOverlappingCollisionWith(tileType: TileType, tilePosition: WorldTilePos)
    mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos, side: Side)
    /// Bool = should stop handling collisions
    mutating func handleCollisionWith(entity otherEntity: Entity)
}