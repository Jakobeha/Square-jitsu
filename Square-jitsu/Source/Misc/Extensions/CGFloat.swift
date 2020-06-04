//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGFloat {
    static let epsilon: CGFloat = 0.0001

    static func %(lhs: CGFloat, modulo: CGFloat) -> CGFloat {
        CGFloat(fmodf(Float(lhs), Float(modulo)))
    }

    static func %=(lhs: inout CGFloat, modulo: CGFloat) {
        lhs = lhs % modulo
    }

    static func areRoughlyEqual(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
        abs(lhs - rhs) <= epsilon
    }

    static func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        (t * (end - start)) + start
    }

    static func reverseLerp(start: CGFloat, end: CGFloat, value: CGFloat) -> CGFloat {
        (value - start) / (end - start)
    }

    static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min <= max)
        if value < min {
            return min
        } else if value > max {
            return max
        } else {
            return value
        }
    }
}
