//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImplicitForcesComponent: SingleSettingCodable, Codable {
    /// It isn't that much
    var gravity: CGFloat
    /// Prevents soft-lock for player and also helps them move other entities along ice
    var minSpeedOnIce: CGFloat
    var solidFriction: CGFloat
    var aerialAngularFriction: CGFloat

    // region encoding and decoding
    typealias AsSetting = StructSetting<ImplicitForcesComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "gravity": CGFloatRangeSetting(0...16),
            "minSpeedOnIce": CGFloatRangeSetting(0...16),
            "solidFriction": CGFloatRangeSetting(0...1),
            "aerialAngularFriction": CGFloatRangeSetting(0...1)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case gravity
        case minSpeedOnIce
        case solidFriction
        case aerialAngularFriction
    }
    // endregion
}
