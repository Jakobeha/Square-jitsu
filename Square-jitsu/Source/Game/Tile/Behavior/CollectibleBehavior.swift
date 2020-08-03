//
// Created by Jakob Hain on 6/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CollectibleBehavior: EmptyTileBehavior<Never> {
    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        let myType = world[pos]
        assert(myType.bigType.asCollectibleType != nil)
    }

    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        if entity.next.ctrC != nil {
            let myType = entity.world![pos]
            let myCollectibleType = myType.bigType.asCollectibleType!
            entity.next.ctrC!.numCollected[myCollectibleType] += 1
            destroyTile(world: entity.world!, pos3D: pos)
        }
    }

    private func destroyTile(world: World, pos3D: WorldTilePos3D) {
        world.destroyTile(pos3D: pos3D)
    }
}
