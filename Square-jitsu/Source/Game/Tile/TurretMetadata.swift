//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TurretMetadata: EmptyTileMetadata {
    var initialTurretDirectionRelativeToAnchor: Angle = -Angle.right
    private var spawned: Bool = false

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

    private func spawn(world: World, pos: WorldTilePos3D) {
        let myTileType = world[pos]
        let turretEntity = Entity.newForSpawnTile(type: myTileType, pos: pos, world: world)

        let initialTurretDirection = myTileType.orientation.toSide.angle + initialTurretDirectionRelativeToAnchor
        turretEntity.next.locC!.rotation = initialTurretDirection

        spawned = true
    }

    // ---

    enum CodingKeys: CodingKey {
        case initialTurretDirectionRelativeToAnchor
    }

    override func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        initialTurretDirectionRelativeToAnchor = try container.decode(Angle.self, forKey: .initialTurretDirectionRelativeToAnchor)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initialTurretDirectionRelativeToAnchor, forKey: .initialTurretDirectionRelativeToAnchor)
    }
}
