//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// When this entity collides with an entity or tile which doesn't destroy on collide it will be moved out of the entity or tile.
/// When it collides with an entity or tile with knockback it will be pushed away more.
/// When it collides with another matter entity both entities will be pushed away more according to each others' mass.
/// When it collides with a dynamic entity it will be pushed more in the entity's direction.
struct MatterComponent: SingleSettingCodable, Codable {
    var mass: CGFloat

    // region encoding and decoding
    typealias AsSetting = StructSetting<MatterComponent>

    static func newSetting() -> AsSetting {
        StructSetting(
            requiredFields: [
                "mass": CGFloatRangeSetting(0...1)
            ],
            optionalFields: [:]
        )
    }
    // endregion
}
