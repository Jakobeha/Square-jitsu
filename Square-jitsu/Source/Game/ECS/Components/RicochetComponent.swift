//
// Created by Jakob Hain on 6/22/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct RicochetComponent: SingleSettingCodable, Codable {
    var bounceMultiplier: CGFloat
    /// 0 = infinite bounces
    var numBouncesBeforeDestroy: Int

    var numBouncesSoFar: Int = 0

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case bounceMultiplier
        case numBouncesBeforeDestroy
    }

    typealias AsSetting = StructSetting<RicochetComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "bounceMultiplier": CGFloatRangeSetting(0...1),
            "numBouncesBeforeDestroy": IntRangeSetting(0...16)
        ], optionalFields: [:])
    }
    // endregion
}
