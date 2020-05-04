//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol TileMetadata: Codable {
    func onLoad(world: World, pos: WorldTilePos)
}

/// Tile is anonymous iff nil
func TileMetadataForTileOf(type: TileBigType) -> TileMetadata? {
    switch (type) {
    case .air, .background, .solid, .ice:
        return nil
    case .shurikenSpawn:
        return ShurikenMetadata()
    case .enemySpawn:
        return EnemyMetadata()
    case .playerSpawn:
        return PlayerMetadata()
    }
}
