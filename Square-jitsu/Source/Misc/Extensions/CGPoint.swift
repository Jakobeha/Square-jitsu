//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static let nan: CGPoint = CGPoint(x: CGFloat.nan, y: CGFloat.nan)

    static prefix func -(point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    static func -=(lhs: inout CGPoint, rhs: CGSize) {
        lhs.x -= rhs.width
        lhs.y -= rhs.height
    }

    static func *(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }

    static func *(lhs: CGPoint, scale: CGSize) -> CGPoint {
        CGPoint(x: lhs.x * scale.width, y: lhs.y * scale.height)
    }

    static func *=(lhs: inout CGPoint, scale: CGFloat) {
        lhs.x *= scale
        lhs.y *= scale
    }

    static func *=(lhs: inout CGPoint, scale: CGSize) {
        lhs.x *= scale.width
        lhs.y *= scale.height
    }

    static func /(lhs: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / scale, y: lhs.y / scale)
    }

    static func /=(lhs: inout CGPoint, scale: CGFloat) {
        lhs.x /= scale
        lhs.y /= scale
    }

    static func %(lhs: CGPoint, modulo: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x % modulo, y: lhs.y % modulo)
    }

    static func %=(lhs: inout CGPoint, modulo: CGFloat) {
        lhs.x %= modulo
        lhs.y %= modulo
    }

    static func dot(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
        (lhs.x * rhs.x) + (lhs.y * rhs.y)
    }

    static func lerp(start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        ((end - start) * t) + start
    }

    var isNaN: Bool {
        x.isNaN && y.isNaN
    }

    init(magnitude: CGFloat, sideDirection: Side) {
        switch sideDirection {
        case .east:
            self.init(x: magnitude, y: 0)
        case .north:
            self.init(x: 0, y: magnitude)
        case .west:
            self.init(x: -magnitude, y: 0)
        case .south:
            self.init(x: 0, y: -magnitude)
        }
    }

    init(magnitude: CGFloat, directionFromOrigin: Angle) {
        self.init(
            x: directionFromOrigin.xOnUnitCircle * magnitude,
            y: directionFromOrigin.yOnUnitCircle * magnitude
        )
    }

    var magnitude: CGFloat {
        hypot(x, y)
    }

    var directionFromOrigin: Angle {
        Angle(radians: atan2(y, x))
    }

    var normalized: CGPoint {
        magnitude < CGFloat.epsilon ? CGPoint.zero : self / magnitude
    }

    var rounded: CGPoint {
        CGPoint(x: round(x), y: round(y))
    }

    var toSize: CGSize {
        CGSize(width: x, height: y)
    }

    func projectOnto(axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return x
        case .vertical:
            return y
        }
    }

    func rotateAroundCenter(by rotation: Angle) -> CGPoint {
        CGPoint(magnitude: magnitude, directionFromOrigin: directionFromOrigin + rotation)
    }
}
