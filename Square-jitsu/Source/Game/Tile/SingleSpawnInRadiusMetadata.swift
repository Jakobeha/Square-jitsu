//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SingleSpawnInRadiusMetadata: EmptyTileMetadata {
    override func tick(world: World, pos: WorldTilePos3D) {
        super.tick(world: world, pos: pos)
        let myTileType = world[pos]
        let spawnRadius = getSpawnRadius(world: world, myTileType: myTileType)
        for entity in world.entities {
            if let locC = entity.next.locC {
                if locC.distance(to: pos.pos.cgPoint) < spawnRadius {
                    spawn(world: world, pos: pos)
                }
            }
        }
    }

    private func spawn(world: World, pos: WorldTilePos3D) {
        let myTileType = world[pos]
        let entity = Entity.newForSpawnTile(type: myTileType, pos: pos, world: world)
        world.add(entity: entity)

        world.set(pos3D: pos, to: TileType.air, persistInGame: true)
    }

    private func getSpawnRadius(world: World, myTileType: TileType) -> CGFloat {
        world.settings.entitySpawnRadius[myTileType]!
    }
}
