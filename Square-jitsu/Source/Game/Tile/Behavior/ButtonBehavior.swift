//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class ButtonBehavior: EmptyTileBehavior<PortalMetadata> {
    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        let myType = entity.world![pos]
        let buttonAction = myType.smallType.asButtonAction
        entity.world!.conduit.perform(buttonAction: buttonAction)
    }
}
