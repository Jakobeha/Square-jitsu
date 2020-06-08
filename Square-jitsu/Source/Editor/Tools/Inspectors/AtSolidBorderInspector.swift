//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class AtSolidBorderInspector: SideBasedOrientationInspector {
    override func isTileConnectableToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        let adjacentTilePosition = tileAtPosition.position.pos.sideAdjacents[side]
        let adjacentTileTypes = world[adjacentTilePosition]
        return !adjacentTileTypes.contains { tileType in tileType.isSolid }
    }

    override func isTileConnectedToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        tileAtPosition.type.orientation.asSideSet.contains(side.toSet)
    }
}
