//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbingComponent {
    var grabbableTypes: Set<TileBigType> = [.shurikenSpawn]
    var grabOffset: CGPoint = CGPoint(x: 0.25, y: -0.25)
    var throwSpeed: CGFloat = 4.5
    var throwAngularSpeed: UnclampedAngle = Angle.right.toUnclamped

    /// Order matters because first grabbed is first thrown
    var grabbed: [EntityRef] = []
}
