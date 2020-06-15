//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Abstract class - override isTileConnectableToSide and isTileConnectedToSide
class SideBasedOrientationInspector: SubInspector {
    private var tiles: [TileAtPosition]
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

        updateConnectedTileInfo()
    }

    func connectTilesTo(side: Side) {
        assert(!tilesConnectableToSide[side].isEmpty)
        let areTilesAlreadyConnected = !tilesConnectedToSide[side].isEmpty

        let tilesToChange = tilesConnectableToSide[side]
        if areTilesAlreadyConnected {
            delegate?.disconnectTilesToSide(tiles: tilesToChange, side: side)

        } else {
            delegate?.connectTilesToSide(tiles: tilesToChange, side: side)
        }

        tiles = tiles.map(world.getUpdatedTileAtPosition)
        updateConnectedTileInfo()

        undoManager.registerUndo(withTarget: self) { this in
            this.connectTilesTo(side: side)
        }
    }

    private func updateConnectedTileInfo() {
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

    func isTileConnectableToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        fatalError("abstract method not implemented")
    }
    
    func isTileConnectedToSide(tileAtPosition: TileAtPosition, side: Side) -> Bool {
        fatalError("abstract method not implemented")
    }
}
