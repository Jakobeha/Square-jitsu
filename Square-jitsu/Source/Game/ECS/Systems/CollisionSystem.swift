//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct CollisionSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    mutating func tick() {
        resetCollisions()
        if handlesTileCollisions {
            handleTileCollisions()
        }
        if handlesNearTileCollisions {
            handleNearTileCollisions()
        }
        if handlesEntityCollisions {
            handleEntityCollisions()
        }
    }

    private func resetCollisions() {
        if entity.next.phyC != nil {
            entity.next.phyC!.reset()
        }
        if entity.next.ntlC != nil {
            entity.next.ntlC!.reset()
        }
    }

    private mutating func handleTileCollisions() {
        assert(handlesTileCollisions)
        for tilePosition in trajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: entity.prev.locC!.radius) {
            let tileTypes = world[tilePosition]
            for tileType in tileTypes {
                handleCollisionWith(tileType: tileType, tilePosition: tilePosition)
                if (entityBlockedFromFurtherCollisions) {
                    return // blocked by other collisions
                }
            }
        }
    }

    private mutating func handleNearTileCollisions() {
        assert(handlesNearTileCollisions)
        let nearRadius = entity.prev.locC!.radius + entity.prev.ntlC!.nearRadiusExtra
        let maxTileDistance = nearRadius + 0.5
        for tilePosition in nearTrajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: nearRadius) {
            let tileDistance = (entity.next.locC!.position - tilePosition.cgPoint).magnitude
            if tileDistance <= maxTileDistance {
                let tileTypes = world[tilePosition]
                for tileType in tileTypes {
                    handleNearCollisionWith(tileType: tileType, tilePosition: tilePosition)
                }
            }
        }
    }

    private mutating func handleEntityCollisions() {
        assert(handlesEntityCollisions)
        let entityCollisions = world.entities.compactMap { otherEntity in
            let radiusForIntersection = entity.prev.locC!.radius + otherEntity.prev.locC!.radius
            let fractionUntilCollision = trajectoryNextFrame.capsuleCastIntersection(capsuleRadius: radiusForIntersection, point: otherEntity.prev.locC!.position)
            if fractionUntilCollision.isNaN {
                // There was no collision (NaN)
                return nil
            } else {
                return (fractionUntilCollision, otherEntity)
            }
        }.sorted { ($0 as (CGFloat, Entity)).0 < $1.0 }
        for (fractionUntilCollision, otherEntity) in entityCollisions {
            handleCollisionWith(entity: otherEntity, fractionOnTrajectory: fractionUntilCollision)
        }
    }

    private var handlesTileCollisions: Bool {
        entity.prev.docC != nil || entity.prev.phyC != nil
    }

    private var handlesNearTileCollisions: Bool {
        entity.prev.ntlC != nil
    }

    private var handlesEntityCollisions: Bool {
        entity.prev.docC != nil || entity.prev.phyC != nil
    }

    private mutating func handleCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        if entity.prev.phyC != nil {
            entity.next.phyC!.overlappingTypes.insert(tileType)
        }
        if tileType.isSolid {
            handleSolidCollisionWith(tileType: tileType, tilePosition: tilePosition)
        }
    }

    private mutating func handleNearCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        assert(entity.prev.ntlC != nil)
        entity.next.ntlC!.nearTypes.insert(tileType)
    }

    private mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        if entity.prev.docC != nil {
            world.remove(entity: entity)
            entity.next.docC!.isRemoved = true
        }
        if entity.prev.phyC != nil {
            // Determine what sides we hit from
            let xIsLeft = trajectoryNextFrame.start.x < trajectoryNextFrame.end.x
            let yIsBottom = trajectoryNextFrame.start.y < trajectoryNextFrame.end.y
            // Determine if we hit from the x axis or y axis.
            let radiusSum = 0.5 + entity.prev.locC!.radius
            let outwardsX = radiusSum * (xIsLeft ? -1 : 1) as CGFloat
            let outwardsY = radiusSum * (yIsBottom ? -1 : 1) as CGFloat
            let xBarrier = tilePosition.cgPoint.x + outwardsX
            let yBarrier = tilePosition.cgPoint.y + outwardsY
            let hitAxis = calculateCollidedAxis(
                    trajectoryNextFrame: trajectoryNextFrame,
                    xIsLeft: xIsLeft,
                    yIsBottom: yIsBottom,
                    xBarrier: xBarrier,
                    yBarrier: yBarrier,
                    tilePosition: tilePosition
            )
            if let hitAxis = hitAxis {
                // Necessary so we don't override velocity - technically we collide this frame but we won't the next
                var isLeaving = false
                switch hitAxis {
                case .horizontal:
                    // We hit from the x axis
                    // Add side, move out of solid, cancel velocity
                    let side = xIsLeft ? SideSet.east : SideSet.west
                    entity.next.phyC!.adjacentSides.insert(side)
                    entity.next.locC!.position.x = xBarrier
                    isLeaving = xIsLeft ? entity.next.dynC!.velocity.x < CGFloat.epsilon : entity.next.dynC!.velocity.x > -CGFloat.epsilon
                    if !isLeaving {
                        entity.next.dynC!.velocity.x = 0
                    }
                case .vertical:
                    // We hit from the y axis
                    // Add side, move out of solid, cancel velocity
                    let side = yIsBottom ? SideSet.north : SideSet.south
                    entity.next.phyC!.adjacentSides.insert(side)
                    entity.next.locC!.position.y = yBarrier
                    isLeaving = yIsBottom ? entity.next.dynC!.velocity.y < CGFloat.epsilon : entity.next.dynC!.velocity.y > -CGFloat.epsilon
                    if !isLeaving {
                        entity.next.dynC!.velocity.y = 0
                    }
                }
                entity.next.phyC!.adjacentPositions.append(tilePosition)
                // Rotate out, cancel angular velocity
                // (even if we didn't actually collide, we should've collided with something else,
                //  so this will happen anyways)
                entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
                if !isLeaving {
                    entity.next.dynC!.angularVelocity = Angle.zero.toUnclamped
                }
            } else if let parallelSide = calculateIfMovingExactlyParallelAlongSideOf(tilePosition: tilePosition, radiusSum: radiusSum) {
                entity.next.phyC!.adjacentSides.insert(parallelSide.toSet)
                entity.next.phyC!.adjacentPositions.append(tilePosition)
                entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
            }
        }
    }

    private var entityBlockedFromFurtherCollisions: Bool {
        (entity.next.docC != nil && entity.next.docC!.isRemoved) ||
                (entity.next.phyC != nil && entity.next.phyC!.adjacentAxes == AxisSet.both)
    }

    private func calculateCollidedAxis(trajectoryNextFrame: Line, xIsLeft: Bool, yIsBottom: Bool, xBarrier: CGFloat, yBarrier: CGFloat, tilePosition: WorldTilePos) -> Axis? {
        let timeToXBarrier = trajectoryNextFrame.tAt(x: xBarrier)
        let timeToYBarrier = trajectoryNextFrame.tAt(y: yBarrier)
        let neverHitXBarrier = timeToXBarrier == nil
        let neverHitYBarrier = timeToYBarrier == nil
        let xSide = xIsLeft ? Side.west : Side.east
        let ySide = yIsBottom ? Side.south : Side.north
        let adjacentXPosition = tilePosition + xSide.offset
        let adjacentYPosition = tilePosition + ySide.offset
        let adjacentXIsBlocked = world[adjacentXPosition].contains { type in type.isSolid }
        let adjacentYIsBlocked = world[adjacentYPosition].contains { type in type.isSolid }
        let adjacentAxes = entity.next.phyC!.adjacentAxes
        let collidedWithXEarlierInTrajectory = adjacentAxes.contains(AxisSet.horizontal)
        let collidedWithYEarlierInTrajectory = adjacentAxes.contains(AxisSet.vertical)
        let xIsImpossible = collidedWithXEarlierInTrajectory || adjacentXIsBlocked || neverHitXBarrier
        let yIsImpossible = collidedWithYEarlierInTrajectory || adjacentYIsBlocked || neverHitYBarrier
        switch (xIsImpossible, yIsImpossible) {
        case (false, false):
            // If we hit a corner it's technically ambiguous.
            // We choose whichever axis is hit first and ignore the other
            return (timeToXBarrier! < timeToYBarrier!) ? .horizontal : .vertical
        case (true, false):
            return .vertical
        case (false, true):
            return .horizontal
        case (true, true):
            // This is inside of a corner (unless physics is broken) so we didn't actually hit it
            return nil
        }
    }

    /// If the entity is moving parallel along a side of this position, it won't be recorded by
    /// calculateCollidedAxis and the entity won't need to adjust position or velocity.
    /// But it will still be a collision and must be recorded to prevent gravity
    private mutating func calculateIfMovingExactlyParallelAlongSideOf(tilePosition: WorldTilePos, radiusSum: CGFloat) -> Side? {
        let isExactlyHorizontal = abs(trajectoryNextFrame.offset.x) < CGFloat.epsilon
        let isExactlyVertical = abs(trajectoryNextFrame.offset.y) < CGFloat.epsilon
        if isExactlyHorizontal {
            let left = tilePosition.cgPoint.x - radiusSum
            let right = tilePosition.cgPoint.x + radiusSum
            if abs(entity.prev.locC!.position.x - left) < CGFloat.epsilon {
                return .east
            } else if abs(entity.prev.locC!.position.x - right) < CGFloat.epsilon {
                return .west
            }
        }
        if isExactlyVertical {
            let bottom = tilePosition.cgPoint.y - radiusSum
            let top = tilePosition.cgPoint.y + radiusSum
            if abs(entity.prev.locC!.position.y - bottom) < CGFloat.epsilon {
                return .north
            } else if abs(entity.prev.locC!.position.y - top) < CGFloat.epsilon {
                return .south
            }
        }
        return nil
    }

    private func handleCollisionWith(entity otherEntity: Entity, fractionOnTrajectory: CGFloat) {
        if entity.prev.docC != nil {
            world.remove(entity: entity)
        }
        if entity.prev.phyC != nil {
            entity.next.phyC!.overlappingEntities.insert(otherEntity)
            // TODO: set otherEntity velocity to lerp between it and this,
            // and this velocity to lerp between this and other (they will have different velocities)
        }
    }

    // Has to be lazy otherwise we would throw on entities without a location component
    private lazy var trajectoryNextFrame: Line =
        // We extend backwards so that the entity can exit if it slightly clips into a solid due to rounding issues
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position).extendedBackwardsBy(magnitude: entity.prev.locC!.radius)

    // Similar definition as trajectoryNextFrame but it's calculated after next entity position might change
    private lazy var nearTrajectoryNextFrame: Line =
        // We extend backwards so that the entity can exit if it slightly clips into a solid due to rounding issues
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position).extendedBackwardsBy(magnitude: entity.prev.locC!.radius + entity.prev.ntlC!.nearRadiusExtra)

}
