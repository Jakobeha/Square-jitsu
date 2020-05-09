//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaComponent {
    enum JumpState: Equatable {
        case idle
        case tryingToJump(direction: Angle)
    }

    var jumpSpeed: CGFloat = 9
    var jumpAngularVelocity: UnclampedAngle = Angle.right.toUnclamped * 2

    var jumpState: JumpState = .idle
    var backgroundTypesUsed: Set<TileSmallType> = []
}
