//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static prefix func -(point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    static func *(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }

    static func *=(lhs: inout CGPoint, scale: CGFloat) {
        lhs.x *= scale
        lhs.y *= scale
    }

    static func /(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / scale, y: lhs.y / scale)
    }

    static func /=(lhs: inout CGPoint, scale: CGFloat) {
        lhs.x /= scale
        lhs.y /= scale
    }

    static func dot(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
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
        magnitude < Constants.cgEpsilon ? CGPoint.zero : self / magnitude
    }
}
