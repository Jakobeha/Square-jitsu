//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Destroys collectibles and keeps track of how many were collected
struct CollectorComponent: SingleSettingCodable, Codable {
    var numCollected: DenseEnumMap<CollectibleType, Int> = DenseEnumMap()

    // region encoding and decoding
    enum CodingKeys: CodingKey {}

    typealias AsSetting = StructSetting<CollectorComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [:], optionalFields: [:])
    }
    // endregion
}
