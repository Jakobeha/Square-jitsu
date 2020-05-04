//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// An entity which will react to tile collisions by sticking to the wall,
/// and other physics entity collisions by pushing the other entity back
class PhysicsEntity: CollidingEntity {
    static let mass: CGFloat = 1
    static let friction: CGFloat = 0.25

    var mass: CGFloat { PhysicsEntity.mass }
    var friction: CGFloat { PhysicsEntity.friction }

    var prevAdjacentSides: SideSet = SideSet.none
    var prevAdjacentPositions: [WorldTilePosition] = []
    var prevCollidedEntities: [Entity] = []
    var nextAdjacentSides: SideSet = SideSet.none
    var nextAdjacentPositions: [WorldTilePosition] = []
    var nextCollidedEntities: [Entity] = []

    override init(position: CGPoint, rotation: Angle = Angle.zero, radius: CGFloat = 0.5) {
        super.init(position: position, rotation: rotation, radius: radius)
    }

    override var handlesTileCollisions: Bool { true }
    override var handlesEntityCollisions: Bool { true }

    override func handleCollisionWith(tile: Tile, tilePosition: WorldTilePos) {
        // Determine what sides we hit from
        let xIsLeft = trajectoryThisFrame.start.x < trajectoryThisFrame.end.x
        let yIsBottom = trajectoryThisFrame.start.y < trajectoryThisFrame.end.y
        // Determine if we hit from the x axis or y axis.
        // If we hit a corner it's tehnically ambiguous.
        // We choose whichever axis is hit first and ignore the other
        let outwardsX = xIsLeft ? -0.5 : 0.5
        let outwardsY = yIsBottom ? -0.5 : 0.5
        let xBarrier = tilePosition.cgPoint.x + outwardsX
        let yBarrier = tilePosition.cgPoint.y + outwardsY
        let timeToXBarrier = trajectoryThisFrame.tAt(x: xBarrier)
        let timeToYBarrier = trajectoryThisFrame.tAt(y: yBarrier)
        if (timeToXBarrier < timeToYBarrier) {
            // We hit from the x axis
            let side = xIsLeft ? SideSet.west : SideSet.east
            // Add side, move out of solid, cancel velocity
            nextAdjacentSides |= side
            nextPosition.x = xBarrier + outwardsX
            velocity.x = 0
        } else {
            // We hit from the y axis
            let side = yIsBottom ? SideSet.south : SideSet.north
            // Add side, move out of solid, cancel velocity
            nextAdjacentSides |= side
            nextPosition.y = yBarrier + outwardsY
            nextVelocity.y = 0
        }
        // Rotate out, cancel angular velocity
        nextAngularVelocity = angularVelocity.round(by: Angle.right)
    }

    override func handleCollisionWith(entity: Entity, fractionOnTrajectory: CGFloat) {
        nextCollidedEntities.append(entity)
        // TODO: Push back
    }

    override func tickVelocity() {
        super.tickVelocity()
        // TODO: Apply friction
    }

    override func tickPhysics() {
        prevAdjacentSides = nextAdjacentSides
        prevCollidedEntities = nextCollidedEntities
        prevAdjacentPositions = nextAdjacentPositions
        nextAdjacentSides = SideSet.none
        nextCollidedEntities = []
        nextAdjacentPositions = []
        super.tickPhysics()
    }
}
