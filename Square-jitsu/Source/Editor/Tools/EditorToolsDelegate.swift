//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol EditorToolsDelegate: AnyObject {
    func performPlaceAction(selectedPositions2D: Set<WorldTilePos>, selectedTileType: TileType)
    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>)
    func performMoveAction(selectedPositions: Set<WorldTilePos3D>, distanceMoved: RelativePos, isCopy: Bool)
    func connectTilesToSide(tiles: [TileAtPosition], side: Side)
    func disconnectTilesToSide(tiles: [TileAtPosition], side: Side)
    func connectTilesToCorner(tiles: [TileAtPosition], corner: Corner)
    func disconnectTilesToCorner(tiles: [TileAtPosition], corner: Corner)
    func setInitialTurretDirections(to initialTurretDirectionsAndPositions: Zip2Sequence<[Angle], [WorldTilePos3D]>)
}
