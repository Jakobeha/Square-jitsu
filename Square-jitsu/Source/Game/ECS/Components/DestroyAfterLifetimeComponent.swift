//
// Created by Jakob Hain on 6/26/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct DestroyAfterLifetimeComponent: SingleSettingCodable, Codable {
    var maxLifetime: CGFloat

    var lifetime: CGFloat = 0

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case maxLifetime
    }

    typealias AsSetting = StructSetting<DestroyAfterLifetimeComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "maxLifetime": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }
    // endregion
}
