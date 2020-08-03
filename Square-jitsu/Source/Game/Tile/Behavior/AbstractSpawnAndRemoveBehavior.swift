//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class AbstractSpawnAndRemoveBehavior<Metadata: TileMetadata>: AbstractSpawnBehavior<Metadata> {
    private var myTileType: TileType?

    @discardableResult func spawnAndRemoveTile(world: World, pos: WorldTilePos3D) -> Entity {
        // Spawn
        let entity = spawn(world: world, pos: pos)

        // Remove tile
        myTileType = world[pos]
        world.destroyTile(pos3D: pos)

        return entity
    }

    override func revert(world: World, pos: WorldTilePos3D) {
        // Remove entities via super.revert
        super.revert(world: world, pos: pos)

        if let myTileType = myTileType {
            // Reset the tile
            world.resetStateAt(pos3D: pos)
            world[pos] = myTileType
            world.resetStateAt(pos3D: pos)
        }
    }
}
