//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct DontClipSystem: SubCollisionSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    mutating func handleOverlappingCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {}

    mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos, side: Side) {
        if entity.next.dciC != nil {
            let radiusSum = entity.next.locC!.radius + 0.5
            switch side {
            case .east:
                let xBarrier = tilePosition.cgPoint.x - radiusSum
                entity.next.locC!.position.x = min(entity.next.locC!.position.x, xBarrier)
            case .north:
                let yBarrier = tilePosition.cgPoint.y - radiusSum
                entity.next.locC!.position.y = min(entity.next.locC!.position.y, yBarrier)
            case .west:
                let xBarrier = tilePosition.cgPoint.x + radiusSum
                entity.next.locC!.position.x = max(entity.next.locC!.position.x, xBarrier)
            case .south:
                let yBarrier = tilePosition.cgPoint.y + radiusSum
                entity.next.locC!.position.y = max(entity.next.locC!.position.y, yBarrier)
            }
        }
    }

    mutating func handleCollisionWith(entity otherEntity: Entity) {}
}
