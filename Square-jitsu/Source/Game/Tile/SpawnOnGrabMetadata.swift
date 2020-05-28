//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class SpawnOnGrabMetadata: AbstractSpawnAndRemoveMetadata {
    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        super.onEntityCollide(entity: entity, pos: pos)
        let world = entity.world!
        let myTileType = world[pos]
        if GrabSystem.canGrab(grabbingEntity: entity, grabbedType: myTileType) {
            let grabbedEntity = spawnAndRemoveTile(world: entity.world!, pos: pos)
            GrabSystem.grab(grabbingEntity: entity, grabbedEntity: grabbedEntity)
        }
    }
}
