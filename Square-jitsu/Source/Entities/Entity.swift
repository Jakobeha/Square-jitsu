//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity {
    private(set) var position: CGPoint
    private(set) var rotation: Angle
    private(set) var radius: CGFloat

    var nextPosition: CGPoint
    var nextRotation: Angle
    var nextRadius: CGFloat

    var trajectoryNextFrame: Line {
        Line(start: position, end: nextPosition)
    }

    weak var world: World? = nil
    var worldIndex: Int = -1

    init(position: CGPoint, rotation: Angle = Angle.zero, radius: CGFloat = 0.5) {
        self.position = position
        self.rotation = rotation
        self.radius = radius
        nextPosition = position
        nextRotation = rotation
        nextRadius = radius
    }

    func tickLocation() {
        position = nextPosition
        rotation = nextRotation
        radius = nextRadius
        world?.loadAround(pos: position)
    }
}
