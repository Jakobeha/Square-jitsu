//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MovingComponent: SingleSettingCodable, Codable {
    var dynamicKnockbackMultiplier: CGFloat

    var velocity: CGPoint = CGPoint.zero
    var angularVelocity: UnclampedAngle = Angle.zero.toUnclamped

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case dynamicKnockbackMultiplier
    }

    typealias AsSetting = StructSetting<MovingComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "dynamicKnockbackMultiplier": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }
    // endregion
}
