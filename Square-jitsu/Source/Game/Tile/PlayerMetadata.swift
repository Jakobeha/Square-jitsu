//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PlayerMetadata: TileMetadata {
    func onLoad(world: World, pos: WorldTilePos) {
        // TODO: Actually create the player entity (need to work more on entities first)
        let player = Entity(Entity.Components(locC: nil, dynC: nil, docC: nil, phyC: nil))
        world.add(entity: player)
        world.player = player
    }
}
