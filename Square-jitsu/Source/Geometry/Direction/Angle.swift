//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Angle: Equatable, Hashable, Codable {
    static let zero: Angle = Angle(radians: 0 as Float)
    static let right: Angle = Angle(radians: Float.pi)

    static func +(lhs: Angle, rhs: Angle) -> Angle {
        Angle(radians: lhs.radians + rhs.radians)
    }

    static func -(lhs: Angle, rhs: Angle) -> Angle {
        Angle(radians: lhs.radians - rhs.radians)
    }

    static func *(lhs: Angle, scale: CGFloat) -> Angle {
        Angle(radians: lhs.radians * Float(scale))
    }

    static func /(lhs: Angle, scale: CGFloat) -> Angle {
        Angle(radians: lhs.radians / Float(scale))
    }

    let radians: Float

    init(radians: CGFloat) {
        self.init(radians: Float(radians))
    }

    init(radians: Float) {
        self.radians = fmodf(radians, Float.pi * 2)
        // TODO: ensure this is how fmod works
        assert(radians >= 0 && radians <= Float.pi * 2)
        if (self.radians > Float.pi) {
            self.radians = (Float.pi * 2) - self.radians
        }
    }

    func round(by unit: Angle) -> Angle {
        return Angle(round(radians / unit.radians) * unit.radians)
    }
}
