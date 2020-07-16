//
// Created by Jakob Hain on 7/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroMetadataInspector<Metadata: TileMetadata>: SubInspector {
    var tiles: [TileAtPosition]
    let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil
    private let undoManager: UndoManager

    var metadata: Metadata {
        get { tiles.first!.metadata! as! Metadata }
        set {
            delegate?.setMetadataOf(tiles: tiles, metadata: newValue)
            reloadTiles()
        }
    }

    init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.tiles = world.getSideAdjacentsOf(tilesAtPositions: tiles)
        self.world = world
        self.delegate = delegate
        self.undoManager = undoManager
    }
}
