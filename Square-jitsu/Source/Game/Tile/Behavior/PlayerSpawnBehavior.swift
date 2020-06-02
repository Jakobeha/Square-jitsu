//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class PlayerSpawnBehavior: EmptyTileBehavior<Never> {
    private struct LoadInfo {
        let playerSpawnWorld: World
        let playerSpawnPos: WorldTilePos3D
    }

    /// Returns a behavior at (0, 0) for a world without a player
    static func dummyForInvalid(world: World) -> PlayerSpawnBehavior {
        let behavior = PlayerSpawnBehavior()
        behavior.loadInfo = LoadInfo(playerSpawnWorld: world, playerSpawnPos: WorldTilePos3D.zero)
        return behavior
    }

    private var loadInfo: LoadInfo?

    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        // Avoid if the tile type is wrong
        let myTileType = world[pos]
        if myTileType.bigType != TileBigType.player {
            Logger.warn("player spawn behavior must be on player spawn tile, ignoring")
            return
        }
        

        if world.playerBehavior == nil {
            // Assign to the world, and the world will spawn the player later
            world.playerBehavior = self

            // Assign load info for when the player will be spawned
            loadInfo = LoadInfo(playerSpawnWorld: world, playerSpawnPos: pos)
        }
        // otherwise the world reset everything except the player, so this behavior just gets discarded.
        // We still need to clear the tile position though

        // Remove so the player tile is no longer visible
        world.set(pos3D: pos, to: TileType.air, persistInGame: true)

    }

    func spawnPlayer() -> Entity {
        // Spawn the player
        let pos = loadInfo!.playerSpawnPos
        let world = loadInfo!.playerSpawnWorld
        return Entity.newForSpawnTile(type: TileType.player, pos: pos, world: world)
    }

    func revert(world: World, pos3D: WorldTilePos3D) {
        fatalError("didn't expect PlayerSpawnBehavior.revert to be called - since player tiles can't be removed in the editor, and the world should explicitly avoid calling revert on the player metadata when resetting everything except for the player")
    }
}
