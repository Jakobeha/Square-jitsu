//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol SliderNumber: Comparable {
    static func round(_ float: CGFloat) -> Self
    var toFloat: CGFloat { get }
}

extension CGFloat: SliderNumber {
    static func round(_ float: CGFloat) -> CGFloat {
        float
    }

    var toFloat: CGFloat { self }
}

extension UnclampedAngle: SliderNumber {
    static func round(_ float: CGFloat) -> UnclampedAngle {
        UnclampedAngle(radians: Float(float))
    }

    var toFloat: CGFloat {
        CGFloat(radians)
    }
}