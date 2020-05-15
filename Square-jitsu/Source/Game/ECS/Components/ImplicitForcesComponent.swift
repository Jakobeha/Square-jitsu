//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImplicitForcesComponent: SettingCodableByCodable, Codable {
    /// It isn't that much
    var gravity: CGFloat
    /// Prevents soft-lock for player and also helps them move other entities along ice
    var minSpeedOnIce: CGFloat
    var solidFriction: CGFloat
    var aerialAngularFriction: CGFloat

    enum CodingKeys: String, CodingKey {
        case gravity
        case minSpeedOnIce
        case solidFriction
        case aerialAngularFriction
    }
}
