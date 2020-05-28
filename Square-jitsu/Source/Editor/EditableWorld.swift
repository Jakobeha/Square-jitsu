//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Synchronises a world file and a world.
/// In gameplay the world file can be forgotten once the world is created,
/// because the world will retain it and use it to load new chunks when necessary,
/// but when editing the file needs to be kept so it can be written to
class EditableWorld: EditableReadonlyStatelessWorld {
    let world: World
    private let worldFile: WorldFile

    var settings: WorldSettings { worldFile.settings }
    var didGetErrorInWorldFile: Observable<Error> { worldFile.didGetError }

    init(worldFile: WorldFile, userSettings: UserSettings) {
        let worldLoader = WorldLoaderFromFile(file: worldFile)
        world = World(loader: worldLoader, settings: worldFile.settings, userSettings: userSettings)
        self.worldFile = worldFile
    }

    // region tile access and mutation
    subscript(pos: WorldTilePos) -> [TileType] {
        worldFile[pos]
    }

    subscript(pos3D: WorldTilePos3D) -> TileType {
        get { worldFile[pos3D] }
        set {
            resetStateAt(pos3D: pos3D)
            worldFile[pos3D] = newValue
            world.set(pos3D: pos3D, to: newValue, persistInGame: false)
        }
    }

    func forceCreateTile(pos: WorldTilePos, type: TileType) {
        world.forceCreateTile(pos: pos, type: type)
        worldFile.forceCreateTile(pos: pos, type: type)
    }

    func destroyTiles(pos: WorldTilePos) {
        world.destroyTiles(pos: pos)
        worldFile.destroyTiles(pos: pos)
    }

    func destroyTile(pos3D: WorldTilePos3D) {
        world.set(pos3D: pos3D, to: TileType.air, persistInGame: false)
        worldFile.destroyTile(pos3D: pos3D)
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
        if let tileMetadata = world.getMetadataAt(pos3D: pos3D) {
            tileMetadata.revert(world: world, pos: pos3D)
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