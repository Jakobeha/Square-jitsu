//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TurretBehavior: AbstractSpawnBehavior<TurretMetadata> {
    override func tick(world: World, pos: WorldTilePos3D) {
        super.tick(world: world, pos: pos)
        if !spawned {
            spawnIfNecessary(world: world, pos: pos)
        }
    }

    private func spawnIfNecessary(world: World, pos: WorldTilePos3D) {
        assert(!spawned)
        for entity in world.entities {
            if let locC = entity.next.locC {
                if locC.distance(to: pos.pos.cgPoint) < TurretComponent.turretVisibilityRadius {
                    spawn(world: world, pos: pos)
                    break
                }
            }
        }
    }
}
