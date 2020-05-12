//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SpawnOnGrabMetadata: EmptyTileMetadata {
    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        super.onEntityCollide(entity: entity, pos: pos)
        let world = entity.world!
        let myTileType = world[pos]
        if GrabSystem.canGrab(grabbingEntity: entity, grabbedType: myTileType) {
            let grabbedEntity = spawn(world: entity.world!, pos: pos)
            GrabSystem.grab(grabbingEntity: entity, grabbedEntity: grabbedEntity)
        }
    }

    private func spawn(world: World, pos: WorldTilePos3D) -> Entity {
        let myTileType = world[pos]
        let entity = Entity.newForSpawnTile(type: myTileType, pos: pos)
        world.add(entity: entity)

        world.set(pos3D: pos, to: TileType.air, persistInGame: true)

        return entity
    }
}
