//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct UnclampedAngle: Equatable, Hashable, Codable, LosslessStringConvertible {
    static prefix func -(angle: UnclampedAngle) -> UnclampedAngle {
        UnclampedAngle(radians: -angle.radians)
    }

    static func +(lhs: UnclampedAngle, rhs: UnclampedAngle) -> UnclampedAngle {
        UnclampedAngle(radians: lhs.radians + rhs.radians)
    }

    static func +=(lhs: inout UnclampedAngle, rhs: UnclampedAngle) {
        lhs.radians += rhs.radians
    }

    static func -(lhs: UnclampedAngle, rhs: UnclampedAngle) -> UnclampedAngle {
        UnclampedAngle(radians: lhs.radians - rhs.radians)
    }

    static func -=(lhs: inout UnclampedAngle, rhs: UnclampedAngle) {
        lhs.radians -= rhs.radians
    }

    static func *(lhs: UnclampedAngle, scale: CGFloat) -> UnclampedAngle {
        UnclampedAngle(radians: lhs.radians * Float(scale))
    }

    static func *=(lhs: inout UnclampedAngle, scale: CGFloat) {
        lhs.radians *= Float(scale)
    }

    static func /(lhs: UnclampedAngle, scale: CGFloat) -> UnclampedAngle {
        UnclampedAngle(radians: lhs.radians / Float(scale))
    }

    static func /=(lhs: inout UnclampedAngle, scale: CGFloat) {
        lhs.radians /= Float(scale)
    }

    static func >(lhs: UnclampedAngle, rhs: UnclampedAngle) -> Bool {
        lhs.radians > rhs.radians
    }

    static func <(lhs: UnclampedAngle, rhs: UnclampedAngle) -> Bool {
        lhs.radians < rhs.radians
    }

    var radians: Float

    var degrees: Float {
        radians * 180 / Float.pi
    }

    init(radians: CGFloat) {
        self.init(radians: Float(radians))
    }

    init(degrees: Float) {
        self.init(radians: degrees * Float.pi / 180)
    }

    init(radians: Float) {
        self.radians = radians
    }

    init?(_ description: String) {
        if description.hasSuffix("°"),
           let degrees = Float(description[..<description.index(before: description.endIndex)]) {
            self.init(degrees: degrees)
        } else {
            return nil
        }
    }

    var description: String { "\(degrees)°" }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let asString = try container.decode(String.self)
        if let angle = UnclampedAngle(asString) {
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
