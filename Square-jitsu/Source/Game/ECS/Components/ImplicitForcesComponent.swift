//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ImplicitForcesComponent {
    /// It isn't that much
    var gravity: CGFloat = 0.25
    /// Prevents soft-lock for player and also helps them move other entities along ice
    var minSpeedOnIce: CGFloat = 2
    var solidFriction: CGFloat = 1.0 / 64
    var aerialAngularFriction: CGFloat = 1.0 / 48
}
