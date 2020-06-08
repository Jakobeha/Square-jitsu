//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Angle: Equatable, Hashable, Codable, LosslessStringConvertible {
    static let zero: Angle = Angle(radians: 0 as Float)
    static let right: Angle = Angle(radians: Float.pi / 2)
    static let straight: Angle = Angle(radians: Float.pi)
    static let circle: Angle = Angle(radians: Float.pi * 2)

    static prefix func -(angle: Angle) -> Angle {
        Angle(radians: -angle.radians)
    }

    static func +(lhs: Angle, rhs: UnclampedAngle) -> Angle {
        Angle(radians: lhs.radians + rhs.radians)
    }

    static func +=(lhs: inout Angle, rhs: UnclampedAngle) {
        lhs = lhs + rhs
    }

    static func -(lhs: Angle, rhs: UnclampedAngle) -> Angle {
        Angle(radians: lhs.radians - rhs.radians)
    }

    static func -(lhs: Angle, rhs: Angle) -> Angle {
        Angle(radians: lhs.radians - rhs.radians)
    }

    static func -=(lhs: inout Angle, rhs: UnclampedAngle) {
        lhs = lhs - rhs
    }

    static func -=(lhs: inout Angle, rhs: Angle) {
        lhs = lhs - rhs
    }

    static func *(lhs: Angle, scale: CGFloat) -> Angle {
        Angle(radians: lhs.radians * Float(scale))
    }

    static func *=(lhs: inout Angle, scale: CGFloat) {
        lhs = lhs * scale
    }

    static func /(lhs: Angle, scale: CGFloat) -> Angle {
        Angle(radians: lhs.radians / Float(scale))
    }

    static func /=(lhs: inout Angle, scale: CGFloat) {
        lhs = lhs / scale
    }

    private static func normalize(radians: Float) -> Float {
        assert(!radians.isNaN && !radians.isInfinite, "sanity check failed")
        var radians = radians
        radians = fmodf(radians, Float.pi * 2)
        if (radians < -Float.pi) {
            radians += Float.pi * 2
        }
        if (radians > Float.pi) {
            radians -= Float.pi * 2
        }
        return radians
    }

    let radians: Float

    var degrees: Float { radians * 180 / Float.pi }

    var toUnclamped: UnclampedAngle { UnclampedAngle(radians: radians) }

    /// Flips the angle if it's between -180° and 0°
    var absolute: Angle { Angle(radians: abs(radians)) }

    var positiveRadians: Float {
        radians < 0 ? (Float.pi * 2) + radians : radians
    }

    var isCounterClockwise: Bool { radians > 0 }

    /// Cosine
    var xOnUnitCircle: CGFloat {
        CGFloat(cos(radians))
    }

    /// Sine
    var yOnUnitCircle: CGFloat {
        CGFloat(sin(radians))
    }

    init(_ unclamped: UnclampedAngle) {
        self.init(radians: unclamped.radians)
    }

    init(radians: CGFloat) {
        self.init(radians: Float(radians))
    }

    init(degrees: Float) {
        self.init(radians: degrees * Float.pi / 180)
    }

    init(radians: Float) {
        self.radians = Angle.normalize(radians: radians)
    }

    func round(by unit: Angle) -> Angle {
        Angle(radians: roundf(radians / unit.radians) * unit.radians)
    }

    init?(_ description: String) {
        if let unclamped = UnclampedAngle(description) {
            self.init(unclamped)
        } else {
            return nil
        }
    }

    var description: String { toUnclamped.description }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let asString = try container.decode(String.self)
        if let angle = Angle(asString) {
            self.init(radians: angle.radians)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "must be of the form ###°")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
