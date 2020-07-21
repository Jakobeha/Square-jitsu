//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Inspector {
    let positions: Set<WorldTilePos3D>
    let world: ReadonlyStatelessWorld
    
    let adjacentToSolidInspector: AdjacentToSolidInspector?
    let directionToCornerInspector: DirectionToCornerInspector?
    let edgeInspector: EdgeInspector?
    let freeSideSetInspector: FreeSideSetInspector?
    let turretInspector: TurretInspector?
    let imageInspector: MacroMetadataInspector<ImageMetadata>?
    let portalInspector: MacroMetadataInspector<PortalMetadata>?

    var subInspectors: [SubInspector] {
        ([
            adjacentToSolidInspector,
            directionToCornerInspector,
            edgeInspector,
            freeSideSetInspector,
            turretInspector,
            imageInspector,
            portalInspector
        ] as [SubInspector?]).compacted
    }

    init(positions: Set<WorldTilePos3D>, world: ReadonlyStatelessWorld, delegate: EditorToolsDelegate?, undoManager: UndoManager) {
        self.positions = positions
        self.world = world
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
        freeSideSetInspector = createSubInspectorIfNecessary(type: FreeSideSetInspector.self) { tileType in
            (world.settings.tileOrientationMeanings[tileType] ?? .unused) == .freeSideSet
        }
        turretInspector = createSubInspectorIfNecessary(type: TurretInspector.self) { tileType in
            tileType.bigType == .turret
        }
        imageInspector = createSubInspectorIfNecessary(type: MacroMetadataInspector.self) { tileType in
            tileType.bigType == .image
        }
        portalInspector = createSubInspectorIfNecessary(type: MacroMetadataInspector.self) { tileType in
            tileType.bigType == .portal
        }
    }

    func reload() {
        for subInspector in subInspectors {
            subInspector.reload()
        }
    }
}
