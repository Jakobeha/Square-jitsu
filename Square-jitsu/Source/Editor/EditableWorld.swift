//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Synchronises a world file and a world.
/// In gameplay the world file can be forgotten once the world is created,
/// because the world will retain it and use it to load new chunks when necessary,
/// but when editing the file needs to be kept so it can be written to
class EditableWorld: WritableStatelessWorld, EditableReadonlyStatelessWorld {
    let world: World
    private let worldFile: WorldFile

    var worldUrl: URL { worldFile.url }
    var settings: WorldSettings { worldFile.settings }
    var didGetErrorInWorldFile: Observable<Error> { worldFile.didGetError }

    init(worldFile: WorldFile, userSettings: UserSettings, conduit: WorldConduit?) {
        let worldLoader = WorldLoaderFromFile(file: worldFile)
        world = World(loader: worldLoader, settings: worldFile.settings, userSettings: userSettings, conduit: conduit)
        self.worldFile = worldFile
    }

    // region tile access
    subscript(pos: WorldTilePos) -> [TileType] {
        worldFile[pos]
    }

    func _getTileTypeAt(pos3D: WorldTilePos3D) -> TileType {
        worldFile[pos3D]
    }

    subscript(pos3D: WorldTilePos3D) -> TileType {
        get { worldFile[pos3D] }
        set {
            worldFile[pos3D] = newValue
            resetStateAt(pos3D: pos3D)
        }
    }

    func getNextFreeLayerAt(pos: WorldTilePos) -> Int? {
        // It needs to be the world file, since the world can have tiles hidden
        worldFile.getNextFreeLayerAt(pos: pos)
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        worldFile.getMetadataAt(pos3D: pos3D)
    }
    // endregion

    // region tile mutation
    func setInternally(pos3D: WorldTilePos3D, to newType: TileType) {
        worldFile.setInternally(pos3D: pos3D, to: newType)
    }

    func destroyTileInternally(pos3D: WorldTilePos3D) {
        worldFile.destroyTileInternally(pos3D: pos3D)
    }

    func destroyTilesInternally(pos: WorldTilePos) {
        worldFile.destroyTilesInternally(pos: pos)
    }

    func finishChangingTileAt(pos3D: WorldTilePos3D, type: TileType) {
        resetStateAt(pos3D: pos3D)
    }

    func finishCreatingTileAt(pos3D: WorldTilePos3D, type: TileType) {
        worldFile.finishCreatingTileAt(pos3D: pos3D, type: type)
        resetStateAt(pos3D: pos3D)
    }

    func finishDestroyingTilesAt(pos: WorldTilePos) {
        worldFile.finishDestroyingTilesAt(pos: pos)
        resetStateAt(pos: pos)
    }
    
    func setMetadataAt(pos3D: WorldTilePos3D, to metadata: TileMetadata?) {
        worldFile.setMetadataAt(pos3D: pos3D, to: metadata)
        resetStateAt(pos3D: pos3D)
    }

    func setTileAtPositionTo(_ tileAtPosition: TileAtPosition) {
        self[tileAtPosition.position] = tileAtPosition.type
        setMetadataAt(pos3D: tileAtPosition.position, to: tileAtPosition.metadata)
    }

    private func autoReorientType(_ type: TileType, pos: WorldTilePos) -> TileOrientation {
        let oldOrientation = type.orientation
        let orientationMeaning = world.settings.tileOrientationMeanings[type] ?? .unused
        switch orientationMeaning {
        case .unused, .freeDirection, .freeSideSet:
            return oldOrientation
        case .directionAdjacentToSolid:
            let sidesWithAdjacentSolid = getSolidAdjacentSidesTo(pos: pos)
            if oldOrientation.asOptionalSide != nil &&
               !sidesWithAdjacentSolid.contains(oldOrientation.asOptionalSide!.toSet),
               let aSideWithAdjacentSolid = sidesWithAdjacentSolid.first {
                return TileOrientation(side: aSideWithAdjacentSolid)
            } else {
                return oldOrientation
            }
        case .directionToCorner:
            if oldOrientation != TileOrientation.none {
                return oldOrientation
            } else {
                let preferredCorner = pos.sideAdjacents.values.compactMap { adjacentPos -> Corner? in
                    let adjacentTypes = self[adjacentPos]
                    let adjacentSameTypeIgnoringOrientation = adjacentTypes.first { adjacentType in
                        adjacentType.withDefaultOrientation == type.withDefaultOrientation
                    }
                    return adjacentSameTypeIgnoringOrientation?.orientation.asCorner
                }.first
                if let preferredCorner = preferredCorner {
                    return TileOrientation(corner: preferredCorner)
                } else {
                    return oldOrientation
                }
            }
        case .atBackgroundBorder:
            let sidesWithAdjacentBackground = getBackgroundAdjacentSidesTo(pos: pos)
            let alreadyOccupiedSides = getOccupiedTileSidesAt(pos: pos, tileLayer: type.bigType.layer)
            var orientationSides = sidesWithAdjacentBackground.inverted.subtracting(alreadyOccupiedSides)
            if type.orientation != TileOrientation.none {
                orientationSides.formIntersection(type.orientation.asSideSet)
            }
            return TileOrientation(sideSet: orientationSides)
        case .atSolidBorder:
            let sidesWithAdjacentSolid = getSolidAdjacentSidesTo(pos: pos)
            let alreadyOccupiedSides = getOccupiedTileSidesAt(pos: pos, tileLayer: type.bigType.layer)
            var orientationSides = sidesWithAdjacentSolid.inverted.subtracting(alreadyOccupiedSides)
            if type.orientation != TileOrientation.none {
                orientationSides.formIntersection(type.orientation.asSideSet)
            }
            return TileOrientation(sideSet: orientationSides)
        }
    }
    // endregion

    // region tile hiding and showing
    /// Hiding is only in-game
    func temporarilyHide(positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            assert(!isInGameAndFileDefinitelyNotSynchronizedAt(pos3D: pos3D), "when hiding or showing a tile at a position, the in-game and file worlds must be synchronized at the position")
        }
        for pos3D in positions {
            world.destroyTile(pos3D: pos3D)
        }
    }

    func showTemporarilyHidden(positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            assert(!isInGameAndFileDefinitelyNotSynchronizedAt(pos3D: pos3D), "when hiding or showing a tile at a position, the in-game and file worlds must be synchronized at the position")
        }

        for pos3D in positions {
            world.setInternally(pos3D: pos3D, to: worldFile[pos3D])
            world.resetStateAt(pos3D: pos3D)
        }
    }
    // endregion

    // region synchronization
    func resetStateAt(pos3D: WorldTilePos3D) {
        // Revert the metadata (might redundantly set tile, but also might remove entities)
        if let tileBehavior = world.getBehaviorAt(pos3D: pos3D) {
            tileBehavior.revert(world: world, pos: pos3D)
            tileBehavior.untypedMetadata = worldFile.getMetadataAt(pos3D: pos3D)
        }

        // Set tile
        world.resetStateAt(pos3D: pos3D)
        world[pos3D] = worldFile[pos3D]
    }

    func resetStateAt(pos: WorldTilePos) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            resetStateAt(pos3D: pos3D)
        }
    }

    /// We don't prove in-game and file are synchronized (too much work), but we can disprove some cases easily.
    /// This is used in sanity assertions
    func isInGameAndFileDefinitelyNotSynchronizedAt(pos3D: WorldTilePos3D) -> Bool {
        world[pos3D] != worldFile[pos3D]
    }
    // endregion

    func saveToDisk() {
        worldFile.saveToDisk()
    }
}