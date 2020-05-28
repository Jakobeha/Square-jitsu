//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Provides empty implementations of all on... handlers
class EmptyTileMetadata: TileMetadata {
    func onFirstLoad(world: World, pos: WorldTilePos3D) {}
    func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {}
    func tick(world: World, pos: WorldTilePos3D) {}
    func revert(world: World, pos: WorldTilePos3D) {}

    // ---

    enum CodingKeys: CodingKey {}

    func decode(from decoder: Decoder) throws {
        let _ = try decoder.container(keyedBy: CodingKeys.self)
    }

    func encode(to encoder: Encoder) throws {
        let _ = encoder.container(keyedBy: CodingKeys.self)
    }
}
