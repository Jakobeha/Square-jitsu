//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Constantly-increasing acceleration (tiles/sec^3)
struct Acceleration3Component: SingleSettingCodable, Codable {
    /// In tiles/sec^3
    var jerk: CGFloat

    var acceleration: CGFloat = 0

    // region encoding and decoding
    enum CodingKeys: CodingKey {
        case jerk
    }

    typealias AsSetting = StructSetting<Acceleration3Component>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "jerk": CGFloatRangeSetting(0...32)
        ], optionalFields: [:])
    }
    // endregion
}
