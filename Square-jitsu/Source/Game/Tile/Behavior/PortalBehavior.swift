//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PortalBehavior: EmptyTileBehavior<PortalMetadata> {
    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        entity.world!.conduit.teleportTo(relativePath: metadata.relativePathToDestination)
    }
}
