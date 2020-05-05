//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGFloat {
    static func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        (t * (end - start)) + start
    }
}