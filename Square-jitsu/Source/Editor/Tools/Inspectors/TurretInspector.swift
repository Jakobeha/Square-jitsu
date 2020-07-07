//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class TurretInspector: SubInspector {
    private let tiles: [TileAtPosition]
    private let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil
    private let undoManager: UndoManager

    private(set) var initialTurretDirections: [Angle] = []

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate
        self.undoManager = undoManager

        updateInitialTurretDirections()
    }

    private func updateInitialTurretDirections() {
        initialTurretDirections = tiles.map { tileAtPosition in
            let turretMetadata = tileAtPosition.metadata! as! TurretMetadata
            return turretMetadata.initialTurretDirectionRelativeToAnchor
        }
    }

    func setInitialTurretDirections(to initialTurretDirection: Angle) {
        setInitialTurretDirections(to: Array(repeating: initialTurretDirection, count: initialTurretDirections.count))
    }

    func setInitialTurretDirections(to newInitialTurretDirections: [Angle]) {
        let oldInitialTurretDirections = newInitialTurretDirections
        initialTurretDirections = newInitialTurretDirections

        delegate?.setInitialTurretDirections(
            to: zip(initialTurretDirections, tiles.map { tileAtPosition in tileAtPosition.position })
        )
        updateInitialTurretDirections()

        undoManager.registerUndo(withTarget: self) { this in
            this.setInitialTurretDirections(to: oldInitialTurretDirections)
        }
    }
}
