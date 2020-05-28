//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol TileMetadata: AliveCodable {
    /// This is guaranteed to be called before all other on... handlers
    func onFirstLoad(world: World, pos: WorldTilePos3D)
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D)
    func tick(world: World, pos: WorldTilePos3D)
    func revert(world: World, pos: WorldTilePos3D)
}