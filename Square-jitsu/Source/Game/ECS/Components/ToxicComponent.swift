//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Damages health entities on collision unless grabbed / thrown / fired by them
struct ToxicComponent {
    var damage: CGFloat = 0.25
    var safeTypes: Set<TileType> = []

    var safeEntities: Set<EntityRef> = []
}
