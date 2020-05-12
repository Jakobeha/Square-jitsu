//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabbableComponent {
    var thrownSpeedMultiplier: CGFloat = 1

    var grabState: GrabState = GrabState.idle
}
