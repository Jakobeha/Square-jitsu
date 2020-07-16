//
// Created by Jakob Hain on 5/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SubInspector: AnyObject {
    var tiles: [TileAtPosition] { get set }
    var world: ReadonlyStatelessWorld { get }

    init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager)
}

extension SubInspector {
    func reloadTiles() {
        tiles = tiles.map(world.getUpdatedTileAtPosition)
    }
}
