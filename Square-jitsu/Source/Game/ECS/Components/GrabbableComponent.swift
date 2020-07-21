//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbableComponent: SingleSettingCodable, Codable {
    var thrownSpeedMultiplier: CGFloat

    var grabState: GrabState = GrabState.idle

    // region encoding and decoding
    typealias AsSetting = StructSetting<GrabbableComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "thrownSpeedMultiplier": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case thrownSpeedMultiplier
    }
    // endregion
}
