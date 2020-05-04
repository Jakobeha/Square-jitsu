//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class DynamicEntity : Entity {
    /// It isn't that much
    static let gravity: CGFloat = 0.25

    var velocity: CGPoint
    var angularVelocity: Angle

    var gravity: CGFloat { DynamicEntity.gravity }

    override init(position: CGPoint, rotation: Angle = Angle.zero, radius: CGFloat = 0.5) {
        super.init(position: position, rotation: rotation, radius: radius)
    }

    func tickVelocity() {
        velocity.y -= gravity * Time.fixedDeltaTime
        nextPosition += velocity * Time.fixedDeltaTime
        nextRotation += angularVelocity * Time.fixedDeltaTime
    }
}
