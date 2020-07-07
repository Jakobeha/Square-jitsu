//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

final class Inspector {
    let adjacentToSolidInspector: AdjacentToSolidInspector?
    let directionToCornerInspector: DirectionToCornerInspector?
    let edgeInspector: EdgeInspector?
    let turretInspector: TurretInspector?

    init(positions: Set<WorldTilePos3D>, world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        let tiles = positions.map(world.getTileAt)

        func createSubInspectorIfNecessary<T: SubInspector>(type: T.Type, filter: (TileType) -> Bool) -> T? {
            let subInspectorTiles = tiles.filter { typeAtPosition in
                filter(typeAtPosition.type)
            }

            if subInspectorTiles.isEmpty {
                return nil
            } else {
                return T(tiles: subInspectorTiles, world: world, delegate: delegate, undoManager: undoManager)
            }
        }

        adjacentToSolidInspector = createSubInspectorIfNecessary(type: AdjacentToSolidInspector.self) { tileType in
            (world.settings.tileOrientationMeanings[tileType] ?? .unused) == .directionAdjacentToSolid
        }
        directionToCornerInspector = createSubInspectorIfNecessary(type: DirectionToCornerInspector.self) { tileType in
            (world.settings.tileOrientationMeanings[tileType] ?? .unused) == .directionToCorner
        }
        edgeInspector = createSubInspectorIfNecessary(type: EdgeInspector.self) { tileType in
            tileType.bigType.layer.doTilesOccupySides
        }
        turretInspector = createSubInspectorIfNecessary(type: TurretInspector.self) { tileType in
            tileType.bigType == .turret
        }
    }
}
