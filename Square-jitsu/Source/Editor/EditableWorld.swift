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

    // region tile access and mutation
    subscript(pos: WorldTilePos) -> [TileType] {
        worldFile[pos]
    }

    subscript(pos3D: WorldTilePos3D) -> TileType {
        get { worldFile[pos3D] }
        set {
            worldFile[pos3D] = newValue
            resetStateAt(pos3D: pos3D)
        }
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        worldFile.getMetadataAt(pos3D: pos3D)
    }

    func setMetadataAt(pos3D: WorldTilePos3D, to metadata: TileMetadata?) {
        worldFile.setMetadataAt(pos3D: pos3D, to: metadata)
        resetStateAt(pos3D: pos3D)
    }

    func forceCreateTile(pos: WorldTilePos, type: TileType) {
        let orientedType = autoReorientType(type, pos: pos)
        world.forceCreateTileNotPersistent(pos: pos, type: orientedType)
        worldFile.forceCreateTile(pos: pos, type: orientedType)
    }

    func destroyTiles(pos: WorldTilePos) {
        world.destroyTilesNotPersistent(pos: pos)
        worldFile.destroyTiles(pos: pos)
    }

    func destroyTile(pos3D: WorldTilePos3D) {
        world.set(pos3D: pos3D, to: TileType.air, persistInGame: false)
        worldFile.destroyTile(pos3D: pos3D)
    }

    func setTileAtPositionTo(_ tileAtPosition: TileAtPosition) {
        self[tileAtPosition.position] = tileAtPosition.type
        setMetadataAt(pos3D: tileAtPosition.position, to: tileAtPosition.metadata)
    }

    private func autoReorientType(_ type: TileType, pos: WorldTilePos) -> TileType {
        var type = type
        let orientationMeaning = world.settings.tileOrientationMeanings[type] ?? .unused
        switch orientationMeaning {
        case .unused:
            break
        case .directionAdjacentToSolid:
            let sidesWithAdjacentSolid = getSolidAdjacentSidesTo(pos: pos)
            if let aSideWithAdjacentSolid = sidesWithAdjacentSolid.first {
                type.orientation = TileOrientation(side: aSideWithAdjacentSolid)
            } else {
                type.orientation = TileOrientation.none
            }
        case .directionToCorner:
            let preferredCorner = pos.sideAdjacents.values.compactMap { adjacentPos -> Corner? in
                let adjacentTypes = self[adjacentPos]
                let adjacentSameTypeIgnoringOrientation = adjacentTypes.first { adjacentType in
                    adjacentType.withDefaultOrientation == type.withDefaultOrientation
                }
                return adjacentSameTypeIgnoringOrientation?.orientation.asCorner
            }.first
            if let preferredCorner = preferredCorner {
                type.orientation = TileOrientation(corner: preferredCorner)
            }
        case .atBackgroundBorder:
            let sidesWithAdjacentBackground = getBackgroundAdjacentSidesTo(pos: pos)
            let alreadyOccupiedSides = getOccupiedTileSidesAt(pos: pos, tileLayer: type.bigType.layer)
            let orientationSides = sidesWithAdjacentBackground.inverted.subtracting(alreadyOccupiedSides)
            type.orientation = TileOrientation(sideSet: orientationSides)
        case .atSolidBorder:
            let sidesWithAdjacentSolid = getSolidAdjacentSidesTo(pos: pos)
            let alreadyOccupiedSides = getOccupiedTileSidesAt(pos: pos, tileLayer: type.bigType.layer)
            let orientationSides = sidesWithAdjacentSolid.inverted.subtracting(alreadyOccupiedSides)
            type.orientation = TileOrientation(sideSet: orientationSides)
        }
        return type
    }
    // endregion

    // region tile hiding and showing
    /// Hiding is only in-game
    func temporarilyHide(positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            assert(!isInGameAndFileDefinitelyNotSynchronizedAt(pos3D: pos3D), "when hiding or showing a tile at a position, the in-game and file worlds must be synchronized at the position")
            world.set(pos3D: pos3D, to: TileType.air, persistInGame: true)
        }
    }

    func showTemporarilyHidden(positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            assert(!isInGameAndFileDefinitelyNotSynchronizedAt(pos3D: pos3D), "when hiding or showing a tile at a position, the in-game and file worlds must be synchronized at the position")
            world.clearPersistentTileTypeAt(pos3D: pos3D)
            world.set(pos3D: pos3D, to: worldFile[pos3D], persistInGame: false)
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
        world.clearPersistentTileTypeAt(pos3D: pos3D)
        world.set(pos3D: pos3D, to: worldFile[pos3D], persistInGame: false)
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