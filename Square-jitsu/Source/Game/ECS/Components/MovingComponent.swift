//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MovingComponent {
    /// It isn't that much
    var gravity: CGFloat = 0.25

    var velocity: CGPoint = CGPoint.zero
    var angularVelocity: Angle = Angle.zero
}
