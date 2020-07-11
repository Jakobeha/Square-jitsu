//
// Created by Jakob Hain on 5/25/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension Collection where Element == Angle {
    func sum() -> UnclampedAngle {
        reduce(Angle.zero.toUnclamped) { $0 + $1.toUnclamped }
    }

    func average() -> Angle? {
        isEmpty ? nil : Angle(sum() / CGFloat(count))
    }
}
