//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Abstract class - override isTileConnectableToCorner and isTileConnectedToCorner
class CornerBasedOrientationInspector: SubInspector {
    var tiles: [TileAtPosition]
    let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil
    private let undoManager: UndoManager

    private(set) var tilesConnectableToCorner: DenseEnumMap<Corner, [TileAtPosition]>! = nil
    private(set) var tilesConnectedToCorner: DenseEnumMap<Corner, [TileAtPosition]>! = nil

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate
        self.undoManager = undoManager

        reloadTileInfo()
    }

    func connectTilesTo(corner: Corner) {
        assert(!tilesConnectableToCorner[corner].isEmpty)
        let areTilesAlreadyConnected = !tilesConnectedToCorner[corner].isEmpty

        let tilesToChange = tilesConnectableToCorner[corner]
        let changedTiles: [TileAtPosition] = tilesToChange.map { tileToChange in
            var changedTile = tileToChange
            changedTile.type.orientation = areTilesAlreadyConnected ?
                    self.removeCornerFromOrientation(type: tileToChange.type, corner: corner) :
                    self.addCornerToOrientation(type: tileToChange.type, corner: corner)
            return changedTile
        }

        delegate?.overwrite(tiles: changedTiles)
    }

    func reloadTileInfo() {
        tilesConnectableToCorner = DenseEnumMap { corner in
            tiles.filter { tileAtPosition in
                self.isTileConnectableToCorner(tileAtPosition: tileAtPosition, corner: corner)
            }
        }
        tilesConnectedToCorner = DenseEnumMap { corner in
            tiles.filter { tileAtPosition in
                self.isTileConnectedToCorner(tileAtPosition: tileAtPosition, corner: corner)
            }
        }
    }

    // region abstract methods
    func isTileConnectableToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        fatalError("abstract method not implemented")
    }

    func isTileConnectedToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        fatalError("abstract method not implemented")
    }
    // endregion

    // region orientation changes
    private func addCornerToOrientation(type: TileType, corner: Corner) -> TileOrientation {
        switch world.settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .freeDirection, .directionAdjacentToSolid, .atBackgroundBorder, .atSolidBorder, .freeSideSet:
            fatalError("orientation isn't corner-based")
        case .directionToCorner:
            return TileOrientation(corner: corner)
        }
    }

    private func removeCornerFromOrientation(type: TileType, corner: Corner) -> TileOrientation {
        switch world.settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .freeDirection, .directionAdjacentToSolid, .atBackgroundBorder, .atSolidBorder, .freeSideSet:
            fatalError("orientation isn't corner-based")
        case .directionToCorner:
            // Can't remove because there is only one side
            return type.orientation
        }
    }
    // endregion
}
