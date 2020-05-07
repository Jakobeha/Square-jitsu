//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class SingleSpawnMetadata: EmptyTileMetadata {
    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        let myTileType = world[pos]
        let entity = Entity.newForSpawnTile(type: myTileType, pos: pos)
        world.add(entity: entity)
    }
}
