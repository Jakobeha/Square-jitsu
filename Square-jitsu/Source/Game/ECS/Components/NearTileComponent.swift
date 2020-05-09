//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Records tiles near an entity but not adjacent or collided
struct NearTileComponent {
    /// The radius around the entity where near tiles will be detected
    var nearRadiusExtra: CGFloat = 0.5

    var nearTypes: TileTypeSet = TileTypeSet()

    var isNearNonIceSolid: Bool {
        nearTypes.contains(bigType: TileBigType.solid)
    }

    var isNearToxicSolid: Bool {
        // nearTypes.contains(bigType: TileBigType.toxic)
        false
    }

    mutating func reset() {
        nearTypes.removeAll()
    }
}
