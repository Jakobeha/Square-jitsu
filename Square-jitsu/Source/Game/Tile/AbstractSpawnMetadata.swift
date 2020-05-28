//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class AbstractSpawnMetadata: EmptyTileMetadata {
    private var mySpawnedEntities: [Entity] = []

    /// Whether this metadata spawned a tile
    var spawned: Bool {
        !mySpawnedEntities.isEmpty
    }
    
    @discardableResult func spawn(world: World, pos: WorldTilePos3D) -> Entity {
        let myTileType = world[pos]
        let entity = Entity.newForSpawnTile(type: myTileType, pos: pos, world: world)
        mySpawnedEntities.append(entity)

        return entity
    }

    override func revert(world: World, pos: WorldTilePos3D) {
        for entity in mySpawnedEntities {
            // Remove the entity (unless it was already removed)
            // If entities make permanent significant changes to the world,
            // they need their own `revert` method which we would call here.
            // Currently entities only spawn brief projectiles which are ok
            if entity.world === world {
                world.remove(entity: entity)
            }
        }
        mySpawnedEntities.removeAll()
    }
}
