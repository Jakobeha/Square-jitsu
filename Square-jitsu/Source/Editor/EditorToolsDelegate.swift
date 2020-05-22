//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol EditorToolsDelegate: AnyObject {
    func performPlaceAction(selectedPositions: Set<WorldTilePos3D>, selectedTileType: TileType)
    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>)
    func performMoveAction(selectedPositions: Set<WorldTilePos3D>, distanceMoved: RelativePos)
}
