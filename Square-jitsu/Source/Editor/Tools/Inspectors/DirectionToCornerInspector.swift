//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

final class DirectionToCornerInspector: CornerBasedOrientationInspector {
    override func isTileConnectableToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        true
    }

    override func isTileConnectedToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        tileAtPosition.type.orientation.asCorner == corner
    }
}
