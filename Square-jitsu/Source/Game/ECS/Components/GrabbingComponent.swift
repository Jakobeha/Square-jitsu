//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbingComponent: SingleSettingCodable, Codable {
    var grabbableTypes: Set<TileBigType>
    var grabOffset: CGPoint
    var throwSpeed: CGFloat
    var throwAngularSpeed: UnclampedAngle

    /// Order matters because first grabbed is first thrown
    var grabbed: [EntityRef] = []

    // region encoding and decoding
    typealias AsSetting = StructSetting<GrabbingComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "grabbableTypes": CollectionSetting<Set<TileBigType>> { SimpleEnumSetting<TileBigType>() },
            "grabOffset": CGPointRangeSetting(x: -1...1, y: -1...1),
            "throwSpeed": CGFloatRangeSetting(0...16),
            "throwAngularSpeed": UnclampedAngleSetting()
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case grabbableTypes
        case grabOffset
        case throwSpeed
        case throwAngularSpeed
    }
    // endregion
}
