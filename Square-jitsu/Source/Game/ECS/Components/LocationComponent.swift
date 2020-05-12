//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LocationComponent {
    var position: CGPoint
    var rotation: Angle = Angle.zero
    var radius: CGFloat = 0.5

    var bounds: CGRect {
        CGRect(
                x: position.x - radius,
                y: position.y - radius,
                width: radius * 2,
                height: radius * 2
        )
    }

    /// Distance from the furthest point on this entity (assuming it's a circle) to the given point
    func distance(to point: CGPoint) -> CGFloat {
        max(0, (position - point).magnitude - radius)
    }
}
