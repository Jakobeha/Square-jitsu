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

        updateConnectedTileInfo()
    }

    func connectTilesTo(corner: Corner) {
        assert(!tilesConnectableToCorner[corner].isEmpty)
        let areTilesAlreadyConnected = !tilesConnectedToCorner[corner].isEmpty

        let tilesToChange = tilesConnectableToCorner[corner]
        if areTilesAlreadyConnected {
            delegate?.disconnectTilesToCorner(tiles: tilesToChange, corner: corner)
        } else {
            delegate?.connectTilesToCorner(tiles: tilesToChange, corner: corner)
        }

        reloadTiles()
        updateConnectedTileInfo()

        undoManager.registerUndo(withTarget: self) { this in
            this.connectTilesTo(corner: corner)
        }
    }

    private func updateConnectedTileInfo() {
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

    func isTileConnectableToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        fatalError("abstract method not implemented")
    }
    
    func isTileConnectedToCorner(tileAtPosition: TileAtPosition, corner: Corner) -> Bool {
        fatalError("abstract method not implemented")
    }
}
