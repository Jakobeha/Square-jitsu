//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }

    static func /(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / scale, y: lhs.y / scale)
    }

    static func dot(lhs: CGPoint, rhs: CGPoint) -> CGFloat {
        (lhs.x * rhs.x) + (lhs.y * rhs.y)
    }

    static func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        ((end - start) * t) + start
    }

    var magnitude: CGFloat {
        hypot(x, y)
    }

    var directionFromOrigin: Angle {
        Angle(radians: atan2(y, x))
    }

    var normalized: CGPoint {
        return magnitude < CGFloat(Constants.epsilon) ? CGPoint.zero : self / magnitude
    }
}
