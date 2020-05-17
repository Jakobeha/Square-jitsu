//
// Created by Jakob Hain on 5/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension SKNode {
    var angle: Angle {
        get { Angle(radians: zRotation) }
        set { zRotation = CGFloat(newValue.radians) }
    }
}
