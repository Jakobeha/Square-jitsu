//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CollisionSystem: System {
    static func tick(entity: Entity) {
        resetCollisions(entity: entity)
        if (handlesTileCollisions(entity: entity)) {
            handleTileCollisions(entity: entity)
        }
        if (handlesEntityCollisions(entity: entity)) {
            handleEntityCollisions(entity: entity)
        }
    }

    private static func resetCollisions(entity: Entity) {
        if (entity.next.phyC != nil) {
            entity.next.phyC!.reset()
        }
    }

    private static func handleTileCollisions(entity: Entity) {
        assert(handlesTileCollisions(entity: entity))
        let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
        for tilePosition in trajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: entity.prev.locC!.radius) {
            let tileTypes = entity.world![tilePosition]
            for tileType in tileTypes {
                if (entityCollidesWith(tileType: tileType)) {
                    handleCollisionWith(tileType: tileType, tilePosition: tilePosition, forEntity: entity)
                    if (entityBlockedFromFurtherCollisions(entity: entity)) {
                        return // blocked by other collisions
                    }
                }
            }
        }
    }

    private static func handleEntityCollisions(entity: Entity) {
        assert(handlesEntityCollisions(entity: entity))
        let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
        let entityCollisions = entity.world!.entities.compactMap { otherEntity in
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
            handleCollisionWith(entity: otherEntity, fractionOnTrajectory: fractionUntilCollision, forEntity: entity)
        }
    }

    private static func entityCollidesWith(tileType: TileType) -> Bool {
        switch tileType.bigType {
        case .solid, .ice:
            return true
        case .air, .background, .shurikenSpawn, .enemySpawn, .playerSpawn:
            return false
        }
    }

    private static func handlesTileCollisions(entity: Entity) -> Bool {
        entity.prev.docC != nil || entity.prev.phyC != nil
    }

    private static func handlesEntityCollisions(entity: Entity) -> Bool {
        entity.prev.docC != nil || entity.prev.phyC != nil
    }

    private static func handleCollisionWith(tileType: TileType, tilePosition: WorldTilePos, forEntity entity: Entity) {
        if (entity.prev.docC != nil) {
            entity.world!.remove(entity: entity)
            entity.next.docC!.isRemoved = true
        }
        if (entity.prev.phyC != nil) {
            let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
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
                    tilePosition: tilePosition,
                    forEntity: entity
            )
            if let hitAxis = hitAxis {
                switch hitAxis {
                case .horizontal:
                    // We hit from the x axis
                    // Add side, move out of solid, cancel velocity
                    let side = xIsLeft ? SideSet.west : SideSet.east
                    entity.next.phyC!.adjacentSides.insert(side)
                    entity.next.locC!.position.x = xBarrier
                    entity.next.dynC!.velocity.x = 0
                case .vertical:
                    // We hit from the y axis
                    // Add side, move out of solid, cancel velocity
                    let side = yIsBottom ? SideSet.south : SideSet.north
                    entity.next.phyC!.adjacentSides.insert(side)
                    entity.next.locC!.position.y = yBarrier
                    entity.next.dynC!.velocity.y = 0
                }
                entity.next.phyC!.adjacentPositions.append(tilePosition)
                // Rotate out, cancel angular velocity
                // (even if we didn't actually collide, we should've collided with something else,
                //  so this will happen anyways)
                entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
                entity.next.dynC!.angularVelocity = Angle.zero
            }
        }
    }

    private static func entityBlockedFromFurtherCollisions(entity: Entity) -> Bool {
        (entity.next.docC != nil && entity.next.docC!.isRemoved) ||
                (entity.next.phyC != nil && entity.next.phyC!.adjacentAxes == AxisSet.both)
    }

    private static func calculateCollidedAxis(trajectoryNextFrame: Line, xIsLeft: Bool, yIsBottom: Bool, xBarrier: CGFloat, yBarrier: CGFloat, tilePosition: WorldTilePos, forEntity entity: Entity) -> Axis? {
        let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
        let timeToXBarrier = trajectoryNextFrame.tAt(x: xBarrier)
        let timeToYBarrier = trajectoryNextFrame.tAt(y: yBarrier)
        let neverHitXBarrier = timeToXBarrier == nil
        let neverHitYBarrier = timeToYBarrier == nil
        let xSide = xIsLeft ? Side.west : Side.east
        let ySide = yIsBottom ? Side.south : Side.north
        let adjacentXPosition = tilePosition + xSide.offset
        let adjacentYPosition = tilePosition + ySide.offset
        let adjacentXIsBlocked = entity.world![adjacentXPosition].contains(where: entityCollidesWith)
        let adjacentYIsBlocked = entity.world![adjacentYPosition].contains(where: entityCollidesWith)
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

    private static func handleCollisionWith(entity otherEntity: Entity, fractionOnTrajectory: CGFloat, forEntity entity: Entity) {
        if (entity.prev.docC != nil) {
            entity.world!.remove(entity: entity)
        }
        if (entity.prev.phyC != nil) {
            entity.next.phyC!.overlappingEntities.append(otherEntity)
            // TODO: set otherEntity velocity to lerp between it and this,
            // and this velocity to lerp between this and other (they will have different velocities)
        }
    }

    private static func getTrajectoryNextFrame(entity: Entity) -> Line {
        // We extend backwards so that the entity can exit if it slightly clips into a solid due to rounding issues
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position).extendedBackwardsBy(magnitude: entity.prev.locC!.radius)
    }
}
