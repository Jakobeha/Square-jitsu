//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbableComponent: SettingCodableByCodable, Codable {
    var thrownSpeedMultiplier: CGFloat

    var grabState: GrabState = GrabState.idle

    enum CodingKeys: String, CodingKey {
        case thrownSpeedMultiplier
    }
}
