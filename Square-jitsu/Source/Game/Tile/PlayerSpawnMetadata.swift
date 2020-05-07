//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PlayerSpawnMetadata: EmptyTileMetadata {
    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        let myTileType = world[pos]
        // TODO: Fail gracefully
        assert(myTileType.bigType == TileBigType.playerSpawn, "player spawn metadata must be on player spawn tile")
        let player = Entity.newForSpawnTile(type: myTileType, pos: pos)
        world.add(entity: player)
        world.player = player
    }
}
