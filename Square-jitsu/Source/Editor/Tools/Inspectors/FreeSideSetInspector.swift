//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

final class FreeSideSetInspector: SideBasedOrientationInspector {
    override func isTileConnectableToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        true
    }

    override func isTileConnectedToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        tileAtPosition.type.orientation.asSideSet.contains(side.toSet)
    }
}
