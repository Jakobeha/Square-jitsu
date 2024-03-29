//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SingleSpawnInRadiusBehavior: AbstractSpawnAndRemoveBehavior<Never> {
    private struct SpawnInfo {
        let tileType: TileType
        let entity: Entity
    }

    private var mySpawn: SpawnInfo? = nil

    override func tick(world: World, pos: WorldTilePos3D) {
        super.tick(world: world, pos: pos)
        let myTileType = world[pos]
        let spawnRadius = getSpawnRadius(world: world, myTileType: myTileType)
        for entity in world.entities {
            if let locC = entity.next.locC {
                if locC.distance(to: pos.pos.cgPoint) < spawnRadius {
                    spawnAndRemoveTile(world: world, pos: pos)
                    break
                }
            }
        }
    }

    private func getSpawnRadius(world: World, myTileType: TileType) -> CGFloat {
        world.settings.entitySpawnRadius[myTileType]!
    }
}
