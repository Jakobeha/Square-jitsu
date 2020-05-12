//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Provides empty implementations of all on... handlers
class EmptyTileMetadata: TileMetadata {
    func onFirstLoad(world: World, pos: WorldTilePos3D) {}
    func onLoad(world: World, pos: WorldTilePos3D) {}
    func onUnload(world: World, pos: WorldTilePos3D) {}
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {}
    func tick(world: World, pos: WorldTilePos3D) {}
}
