//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

final class FreeDirectionInspector: SideBasedOrientationInspector {
    override func isTileConnectableToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        world.getSolidAdjacentSidesTo(pos: tileAtPosition.position.pos).contains(side.toSet)
    }

    override func isTileConnectedToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        true
    }
}