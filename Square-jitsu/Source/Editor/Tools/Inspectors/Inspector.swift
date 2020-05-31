//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Inspector {
    let adjacentToSolidInspector: AdjacentToSolidInspector?
    let turretInspector: TurretInspector?

    init(positions: Set<WorldTilePos3D>, world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?) {
        let tiles = positions.map { pos3D in
            TileAtPosition(type: world[pos3D], position: pos3D)
        }
        let world = world
        let delegate = delegate

        func createSubInspectorIfNecessary<T: SubInspector>(type: T.Type, filter: (TileType) -> Bool) -> T? {
            let subInspectorTiles = tiles.filter { typeAtPosition in
                filter(typeAtPosition.type)
            }

            if subInspectorTiles.isEmpty {
                return nil
            } else {
                return T(tiles: subInspectorTiles, world: world, delegate: delegate)
            }
        }

        adjacentToSolidInspector = createSubInspectorIfNecessary(type: AdjacentToSolidInspector.self) { tileType in
            (world.settings.tileOrientationMeanings[tileType] ?? .unused) == .directionAdjacentToSolid
        }
        turretInspector = createSubInspectorIfNecessary(type: TurretInspector.self) { tileType in
            tileType.bigType == .turret
        }
    }
}
