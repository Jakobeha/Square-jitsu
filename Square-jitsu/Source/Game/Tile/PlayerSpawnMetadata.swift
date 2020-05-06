//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PlayerSpawnMetadata: EmptyTileMetadata {
    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        let myTile = world[pos]
        let player = Entity.newForSpawnTile(type: myTile.type)
        world.add(entity: player)
        world.player = player
    }
}
