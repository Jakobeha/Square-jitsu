//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaComponent {
    var jumpSpeed: CGFloat = 9
    var jumpAngularSpeed: UnclampedAngle = Angle.right.toUnclamped * 2

    var actionState: NinjaActionState = .idle
    var backgroundTypesUsed: Set<TileType> = []
}
