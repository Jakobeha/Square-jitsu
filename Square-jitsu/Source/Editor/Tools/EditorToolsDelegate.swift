//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol EditorToolsDelegate: AnyObject {
    func performPlaceAction(selectedPositions2D: Set<WorldTilePos>, selectedTileType: TileType)
    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>)
    func performMoveAction(selectedPositions: Set<WorldTilePos3D>, distanceMoved: RelativePos, isCopy: Bool)
    /// Replaces the original tile and metadata at each given tile-at-position's position
    func overwrite(tiles: [TileAtPosition])
}
