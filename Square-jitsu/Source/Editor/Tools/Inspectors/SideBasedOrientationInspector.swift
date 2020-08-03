//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Abstract class - override isTileConnectableToSide and isTileConnectedToSide
class SideBasedOrientationInspector: SubInspector {
    var tiles: [TileAtPosition]
    let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil
    private let undoManager: UndoManager

    private(set) var tilesConnectableToSide: DenseEnumMap<Side, [TileAtPosition]>! = nil
    private(set) var tilesConnectedToSide: DenseEnumMap<Side, [TileAtPosition]>! = nil

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate
        self.undoManager = undoManager
        
        reloadTileInfo()
    }

    func connectTilesTo(side: Side) {
        assert(!tilesConnectableToSide[side].isEmpty)
        let areTilesAlreadyConnected = !tilesConnectedToSide[side].isEmpty

        let tilesToChange = tilesConnectableToSide[side]
        let changedTiles: [TileAtPosition] = tilesToChange.map { tileToChange in
            var changedTile = tileToChange
            changedTile.type.orientation = areTilesAlreadyConnected ?
                self.removeSideFromOrientation(type: tileToChange.type, side: side) :
                self.addSideToOrientation(type: tileToChange.type, side: side)
            return changedTile
        }

        delegate?.overwrite(tiles: changedTiles)
    }

    func reloadTileInfo() {
        tilesConnectableToSide = DenseEnumMap { side in
            tiles.filter { tileAtPosition in
                self.isTileConnectableToSide(tileAtPosition: tileAtPosition, side: side)
            }
        }
        tilesConnectedToSide = DenseEnumMap { side in
            tiles.filter { tileAtPosition in
                self.isTileConnectedToSide(tileAtPosition: tileAtPosition, side: side)
            }
        }
    }

    // region abstract methods
    func isTileConnectableToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        fatalError("abstract method not implemented")
    }
    
    func isTileConnectedToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        fatalError("abstract method not implemented")
    }
    // endregion

    // region orientation changes
    private func addSideToOrientation(type: TileType, side: Side) -> TileOrientation {
        switch world.settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionToCorner:
            fatalError("orientation isn't side-based")
        case .freeDirection, .directionAdjacentToSolid:
            return TileOrientation(side: side)
        case .atBackgroundBorder, .atSolidBorder, .freeSideSet:
            var orientation = type.orientation
            orientation.asSideSet.insert(side.toSet)
            return orientation
        }
    }

    private func removeSideFromOrientation(type: TileType, side: Side) -> TileOrientation {
        var orientation = type.orientation

        switch world.settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionToCorner:
            fatalError("orientation isn't side-based")
        case .freeDirection, .directionAdjacentToSolid:
            if side == orientation.asOptionalSide {
                return TileOrientation(optionalSide: nil)
            } else {
                return orientation
            }
        case .atBackgroundBorder, .atSolidBorder, .freeSideSet:
            orientation.asSideSet.remove(side.toSet)
            return orientation
        }
    }
    // endregion
}
