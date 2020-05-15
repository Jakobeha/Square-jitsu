//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Damages health entities on collision unless grabbed / thrown / fired by them
struct ToxicComponent: SettingCodableByCodable, Codable {
    var damage: CGFloat
    var safeTypes: Set<TileType>
    var onlyToxicIfThrown: Bool

    var safeEntities: Set<EntityRef> = []

    enum CodingKeys: String, CodingKey {
        case damage
        case safeTypes
        case onlyToxicIfThrown
    }
}
