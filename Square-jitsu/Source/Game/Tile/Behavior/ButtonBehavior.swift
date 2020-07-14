//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class ButtonBehavior: EmptyTileBehavior<PortalMetadata> {
    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        performAction(world: entity.world!, pos3D: pos)
    }

    func performAction(world: ReadonlyWorld, pos3D: WorldTilePos3D) {
        let myType = world[pos3D]
        let buttonAction = myType.smallType.asButtonAction
        world.conduit.perform(buttonAction: buttonAction)
    }
}
