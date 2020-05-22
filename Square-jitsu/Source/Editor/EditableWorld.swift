//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Synchronises a world file and a world.
/// In gameplay the world file can be forgotten once the world is created,
/// because the world will retain it and use it to load new chunks when necessary,
/// but when editing the file needs to be kept so it can be written to
class EditableWorld {
    let world: World
    private let worldFile: WorldFile

    var didGetErrorInWorldFile: Observable<Error> { worldFile.didGetError }

    init(worldFile: WorldFile, userSettings: UserSettings) {
        let worldLoader = WorldLoaderFromFile(file: worldFile)
        world = World(loader: worldLoader, settings: worldFile.settings, userSettings: userSettings)
        self.worldFile = worldFile
    }

    subscript(pos3D: WorldTilePos3D) -> TileType {
        get { world[pos3D] }
        set {
            world.set(pos3D: pos3D, to: newValue, persistInGame: false)
            worldFile[pos3D] = newValue
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

    func saveToDisk() {
        worldFile.saveToDisk()
    }
}