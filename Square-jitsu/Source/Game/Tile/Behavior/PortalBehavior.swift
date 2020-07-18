//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PortalBehavior: EmptyTileBehavior<PortalMetadata> {
    private var teleported: Bool = false

    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        if !teleported {
            entity.world!.conduit.teleportTo(relativePath: metadata.relativePathToDestination)
            teleported = true
        }
    }

    override func revert(world: World, pos: WorldTilePos3D) {
        teleported = false
    }
}
