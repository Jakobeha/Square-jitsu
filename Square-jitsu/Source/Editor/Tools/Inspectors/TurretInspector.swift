//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TurretInspector: SubInspector {
    private let tiles: [TileAtPosition]
    private let world: ReadonlyStatelessWorld
    private weak var delegate: EditorToolsDelegate? = nil

    private(set) var initialTurretDirections: Set<Angle> = []

    required init(tiles: [TileAtPosition], world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?) {
        self.tiles = tiles
        self.world = world
        self.delegate = delegate

        updateInitialTurretDirections()
    }

    private func updateInitialTurretDirections() {
        initialTurretDirections = Set(tiles.map { tileAtPosition in
            let turretMetadata = world.getMetadataAt(pos3D: tileAtPosition.position) as! TurretMetadata
            return turretMetadata.initialTurretDirectionRelativeToAnchor
        })
    }

    func setInitialTurretDirections(to initialTurretDirection: Angle) {
        delegate?.setInitialTurretDirections(
            to: initialTurretDirection,
            positions: Set(tiles.map { tileAtPosition in tileAtPosition.position })
        )
        updateInitialTurretDirections()
    }
}
