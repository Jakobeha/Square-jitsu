//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbingComponent: SettingCodableByCodable, Codable {
    var grabbableTypes: Set<TileBigType>
    var grabOffset: CGPoint
    var throwSpeed: CGFloat
    var throwAngularSpeed: UnclampedAngle

    /// Order matters because first grabbed is first thrown
    var grabbed: [EntityRef] = []

    enum CodingKeys: String, CodingKey {
        case grabbableTypes
        case grabOffset
        case throwSpeed
        case throwAngularSpeed
    }
}
