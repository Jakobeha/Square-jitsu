//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct AccelerationComponent: SingleSettingCodable, Codable {
    /// In tiles/sec^2
    var acceleration: CGFloat

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case acceleration
    }

    typealias AsSetting = StructSetting<AccelerationComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "acceleration": CGFloatRangeSetting(0...32)
        ], optionalFields: [:])
    }
    // endregion
}
