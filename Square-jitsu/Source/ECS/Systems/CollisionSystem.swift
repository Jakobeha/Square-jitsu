//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CollisionSystem: System {
    static func tick(entity: Entity) {
        if (handlesTileCollisions(entity: entity)) {
            handleTileCollisions(entity: entity)
        }
        if (handlesEntityCollisions(entity: entity)) {
            handleEntityCollisions(entity: entity)
        }
    }

    private static func handleTileCollisions(entity: Entity) {
        assert(handlesTileCollisions(entity: entity))
        let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
        for tilePosition in trajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: entity.prev.locC!.radius) {
            let tiles = entity.world![tilePosition]
            for tile in tiles {
                if (entitiesCollideWith(tile: tile)) {
                    handleCollisionWith(tile: tile, tilePosition: tilePosition, forEntity: entity)
                    return // blocked by other collisions
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
            if fractionUntilCollision != fractionUntilCollision {
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

    private static func entitiesCollideWith(tile: Tile) -> Bool {
        switch tile.type.bigType {
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

    private static func handleCollisionWith(tile: Tile, tilePosition: WorldTilePos, forEntity entity: Entity) {
        if (entity.prev.docC != nil) {
            entity.world!.remove(entity: entity)
        }
        if (entity.prev.phyC != nil) {
            let trajectoryNextFrame = getTrajectoryNextFrame(entity: entity)
            // Determine what sides we hit from
            let xIsLeft = trajectoryNextFrame.start.x < trajectoryNextFrame.end.x
            let yIsBottom = trajectoryNextFrame.start.y < trajectoryNextFrame.end.y
            // Determine if we hit from the x axis or y axis.
            // If we hit a corner it's tehnically ambiguous.
            // We choose whichever axis is hit first and ignore the other
            let outwardsX = (xIsLeft ? -0.5 : 0.5) as CGFloat
            let outwardsY = (yIsBottom ? -0.5 : 0.5) as CGFloat
            let xBarrier = tilePosition.cgPoint.x + outwardsX
            let yBarrier = tilePosition.cgPoint.y + outwardsY
            let timeToXBarrier = trajectoryNextFrame.tAt(x: xBarrier)
            let timeToYBarrier = trajectoryNextFrame.tAt(y: yBarrier)
            if (timeToXBarrier < timeToYBarrier) {
                // We hit from the x axis
                let side = xIsLeft ? SideSet.west : SideSet.east
                // Add side, move out of solid, cancel velocity
                entity.next.phyC!.adjacentSides.insert(side)
                entity.next.locC!.position.x = xBarrier + outwardsX
                entity.next.dynC!.velocity.x = 0
            } else {
                // We hit from the y axis
                let side = yIsBottom ? SideSet.south : SideSet.north
                // Add side, move out of solid, cancel velocity
                entity.next.phyC!.adjacentSides.insert(side)
                entity.next.locC!.position.y = yBarrier + outwardsY
                entity.next.dynC!.velocity.y = 0
            }
            // Rotate out, cancel angular velocity
            entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
            entity.next.dynC!.angularVelocity = Angle.zero
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
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position)
    }
}
