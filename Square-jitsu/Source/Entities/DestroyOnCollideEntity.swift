//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class DestroyOnCollideEntity: CollidingEntity {
    override init(position: CGPoint, rotation: Angle = Angle.zero, radius: CGFloat = 0.5) {
        super.init(position: position, rotation: rotation, radius: radius)
    }

    override var handlesTileCollisions: Bool { true }
    override var handlesEntityCollisions: Bool { true }

    override func handleCollisionWith(tile: Tile, tilePosition: WorldTilePos) {
        world!.remove(entity: self)
    }

    override func handleCollisionWith(entity: Entity, fractionOnTrajectory: CGFloat) {
        world!.remove(entity: self)
    }
}
