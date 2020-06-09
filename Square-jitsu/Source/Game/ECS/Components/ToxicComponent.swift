//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Damages health entities on collision unless grabbed / thrown / fired by them
struct ToxicComponent: SingleSettingCodable, Codable {
    var damage: CGFloat
    var safeTypes: Set<TileType>

    var safeEntities: Set<EntityRef> = []

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case damage
        case safeTypes
    }

    typealias AsSetting = StructSetting<ToxicComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "damage": CGFloatRangeSetting(0...1),
            "safeTypes": CollectionSetting<Set<TileType>> { TileTypeSetting() }
        ], optionalFields: [:])
    }
    // endregion
}
