//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct MovingComponent: SettingCodableByCodable, Codable {
    var velocity: CGPoint = CGPoint.zero
    var angularVelocity: UnclampedAngle = Angle.zero.toUnclamped
}
