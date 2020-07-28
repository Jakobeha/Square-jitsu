//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class TurretInspector: SubInspector {
    var tiles: [TileAtPosition]
    let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil
    private let undoManager: UndoManager

    private(set) var initialTurretDirections: [Angle] = []
    var rotatesClockwise: Bool? {
        get { (tiles.first!.metadata! as! TurretMetadata).rotatesClockwise }
        set {
            let newTiles: [TileAtPosition] = tiles.map { tileAtPosition in
                var newTile = tileAtPosition
                var newMetadata = newTile.metadata as! TurretMetadata
                newMetadata.rotatesClockwise = newValue
                newTile.metadata = newMetadata
                return newTile
            }
            delegate?.overwrite(tiles: newTiles)
        }
    }

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate
        self.undoManager = undoManager

        reloadTileInfo()
    }

    func reloadTileInfo() {
        initialTurretDirections = tiles.map { tileAtPosition in
            let turretMetadata = tileAtPosition.metadata! as! TurretMetadata
            return turretMetadata.initialTurretDirectionRelativeToAnchor
        }
    }

    func setInitialTurretDirections(to initialTurretDirection: Angle) {
        let newTiles: [TileAtPosition] = tiles.map { tileAtPosition in
            var newTile = tileAtPosition
            var newMetadata = newTile.metadata as! TurretMetadata
            newMetadata.initialTurretDirectionRelativeToAnchor = initialTurretDirection
            newTile.metadata = newMetadata
            return newTile
        }
        delegate?.overwrite(tiles: newTiles)
    }
}
