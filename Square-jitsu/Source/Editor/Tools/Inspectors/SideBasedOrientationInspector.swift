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

    private(set) var tilesConnectableToSide: DenseEnumMap<Side, [TileAtPosition]>! = nil
    private(set) var tilesConnectedToSide: DenseEnumMap<Side, [TileAtPosition]>! = nil

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate

        updateConnectedTileInfo()
    }

    func connectTilesTo(side: Side) {
        let tilesToChange = tilesConnectableToSide[side]
        delegate?.connectTilesToSide(tiles: tilesToChange, side: side)

        tiles = tiles.map(world.getUpdatedTileAtPosition)
        updateConnectedTileInfo()
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
