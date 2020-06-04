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

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    mutating func tick() {
        resetCollisions()
        if handlesTileCollisions {
            handleTileCollisions()
        }
        if handlesEntityCollisions {
            handleEntityCollisions()
        }
    }

    private func resetCollisions() {
        if entity.next.phyC != nil {
            entity.next.phyC!.reset()
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

    private mutating func handleEntityCollisions() {
        assert(handlesEntityCollisions)
        let entityCollisions = world.entities.compactMap { otherEntity in
            if entity == otherEntity {
                // Entity can't collide with itself
                return nil
            } else if otherEntity.next.locC != nil {
                let radiusForIntersection = entity.next.locC!.radius + otherEntity.next.locC!.radius
                let fractionUntilCollision = trajectoryNextFrame.capsuleCastIntersection(capsuleRadius: radiusForIntersection, point: otherEntity.next.locC!.position)
                if fractionUntilCollision.isNaN {
                    // There was no collision (NaN)
                    return nil
                } else {
                    return (fractionUntilCollision, otherEntity)
                }
            } else if otherEntity.next.lilC != nil {
                let radiusForIntersection = entity.next.locC!.radius + otherEntity.next.lilC!.thickness
                let fractionUntilCollision = trajectoryNextFrame.capsuleCastIntersection(capsuleRadius: radiusForIntersection, otherLine: otherEntity.next.lilC!.position)
                if fractionUntilCollision.isNaN {
                    // There was no collision (NaN)
                    return nil
                } else {
                    return (fractionUntilCollision, otherEntity)
                }
            } else {
                // No position = can't collide
                return nil
            }
        }.sorted { ($0 as (CGFloat, Entity)).0 < $1.0 }
        for (fractionUntilCollision, otherEntity) in entityCollisions {
            if shouldCollideWith(entity: otherEntity) {
                handleCollisionWith(entity: otherEntity, fractionOnTrajectory: fractionUntilCollision)
            }
        }
    }

    private var handlesTileCollisions: Bool {
        ((entity.prev.docC != nil && entity.prev.docC!.destroyOnSolidCollision) || entity.prev.phyC != nil) &&
        !(entity.prev.graC?.grabState.isGrabbed ?? false)
    }

    private var handlesEntityCollisions: Bool {
        ((entity.prev.docC != nil && entity.prev.docC!.destroyOnEntityCollision) || entity.prev.phyC != nil) &&
        !(entity.prev.graC?.grabState.isGrabbed ?? false)
    }

    private mutating func handleCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        // Insert into overlapping types
        if entity.prev.phyC != nil {
            entity.next.phyC!.overlappingTypes.insert(tileType)
            entity.next.phyC!.overlappingPositions.insert(tilePosition)
        }

        // Handle if solid
        if tileType.isSolid {
            handleSolidCollisionWith(tileType: tileType, tilePosition: tilePosition)
        }

        // Notify metadatas
        for layer in 0..<Chunk.numLayers {
            let pos3D = WorldTilePos3D(pos: tilePosition, layer: layer)
            if let tileBehavior = world.getBehaviorAt(pos3D: pos3D) {
                tileBehavior.onEntityCollide(entity: entity, pos: pos3D)
            }
        }
    }

    private mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        if entity.prev.docC?.destroyOnSolidCollision ?? false {
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
            if calculateIfTileIsCorner(tilePosition: tilePosition, radiusSum: radiusSum) {
                // Not a solid collision, prevent the other cases
            } else if let parallelSide = calculateIfMovingExactlyParallelAlongSideOf(tilePosition: tilePosition, radiusSum: radiusSum) {
                // Fix entity position and velocity if it's slightly clipped or moving into tile
                switch parallelSide {
                case .east:
                    //entity.next.locC!.position.x = min(entity.next.locC!.position.x, outwardsX)
                    entity.next.dynC!.velocity.x = min(entity.next.dynC!.velocity.x, 0)
                case .north:
                    //entity.next.locC!.position.y = min(entity.next.locC!.position.y, outwardsY)
                    entity.next.dynC!.velocity.y = min(entity.next.dynC!.velocity.y, 0)
                case .west:
                    //entity.next.locC!.position.x = max(entity.next.locC!.position.x, outwardsX)
                    entity.next.dynC!.velocity.x = max(entity.next.dynC!.velocity.x, 0)
                case .south:
                    //entity.next.locC!.position.y = max(entity.next.locC!.position.y, outwardsY)
                    entity.next.dynC!.velocity.y = max(entity.next.dynC!.velocity.y, 0)
                }

                // Fix rotation
                entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)

                // Add collision to state
                entity.next.phyC!.adjacentSides.insert(parallelSide.toSet)
                entity.next.phyC!.adjacentPositions.append(key: parallelSide, tilePosition)
            } else if let hitAxis = calculateCollidedAxis(
                    trajectoryNextFrame: trajectoryNextFrame,
                    xIsLeft: xIsLeft,
                    yIsBottom: yIsBottom,
                    xBarrier: xBarrier,
                    yBarrier: yBarrier,
                    tilePosition: tilePosition
            ) {
                // Necessary so we don't override velocity - technically we collide this frame but we won't the next
                var side: Side! = nil
                var isLeaving = false
                switch hitAxis {
                case .horizontal:
                    // We hit from the x axis
                    // Add side, move out of solid, cancel velocity
                    side = xIsLeft ? Side.east : Side.west
                    entity.next.phyC!.adjacentSides.insert(side.toSet)
                    entity.next.locC!.position.x = xBarrier
                    isLeaving = xIsLeft ? entity.next.dynC!.velocity.x < -CGFloat.epsilon : entity.next.dynC!.velocity.x > CGFloat.epsilon
                    if !isLeaving {
                        entity.next.dynC!.velocity.x = 0
                    }
                case .vertical:
                    // We hit from the y axis
                    // Add side, move out of solid, cancel velocity
                    side = yIsBottom ? Side.north : Side.south
                    entity.next.phyC!.adjacentSides.insert(side.toSet)
                    entity.next.locC!.position.y = yBarrier
                    isLeaving = yIsBottom ? entity.next.dynC!.velocity.y < -CGFloat.epsilon : entity.next.dynC!.velocity.y > CGFloat.epsilon
                    if !isLeaving {
                        entity.next.dynC!.velocity.y = 0
                    }
                }
                entity.next.phyC!.adjacentPositions.append(key: side, tilePosition)
                // Rotate out, cancel angular velocity
                // (even if we didn't actually collide, we should've collided with something else,
                //  so this will happen anyways)
                entity.next.locC!.rotation = entity.next.locC!.rotation.round(by: Angle.right)
                if !isLeaving {
                    entity.next.dynC!.angularVelocity = Angle.zero.toUnclamped
                }
            }
        }
    }

    private var entityBlockedFromFurtherCollisions: Bool {
        entity.next.docC?.isRemoved ?? false
    }

    /// Calculate if the tile is a corner, in which case we don't have a solid collision
    /// so the player can slide through 1-block areas
    private mutating func calculateIfTileIsCorner(tilePosition: WorldTilePos, radiusSum: CGFloat) -> Bool {
        let isExactlyHorizontal = abs(trajectoryNextFrame.offset.x) < CGFloat.epsilon
        let isExactlyVertical = abs(trajectoryNextFrame.offset.y) < CGFloat.epsilon
        if isExactlyHorizontal && isExactlyVertical {
            let left = tilePosition.cgPoint.x - radiusSum
            let right = tilePosition.cgPoint.x + radiusSum
            let bottom = tilePosition.cgPoint.y - radiusSum
            let top = tilePosition.cgPoint.y + radiusSum
            let isOnLeftOrRight =
                    abs(entity.prev.locC!.position.x - left) < CGFloat.epsilon ||
                            abs(entity.prev.locC!.position.x - right) < CGFloat.epsilon
            let isOnBottomOrTop =
                    abs(entity.prev.locC!.position.y - bottom) < CGFloat.epsilon ||
                            abs(entity.prev.locC!.position.y - top) < CGFloat.epsilon
            if isOnLeftOrRight && isOnBottomOrTop {
                // Is a corner - ignore
                return true
            }
        }
        return false
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
        let adjacentSides = entity.next.phyC!.adjacentSides
        let collidedWithXEarlierInTrajectory = adjacentSides.contains(xSide.toSet)
        let collidedWithYEarlierInTrajectory = adjacentSides.contains(ySide.toSet)
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

    private func shouldCollideWith(entity otherEntity: Entity) -> Bool {
        entity.prev.graC?.grabState.grabbedOrThrownBy != otherEntity
    }

    private func handleCollisionWith(entity otherEntity: Entity, fractionOnTrajectory: CGFloat) {
        if destroyOnEntityCollisionWith(otherEntity: otherEntity) {
            world.remove(entity: entity)
            entity.next.docC!.isRemoved = true
        }
        if entity.prev.phyC != nil {
            entity.next.phyC!.overlappingEntities.insert(otherEntity)
            // TODO: set otherEntity velocity to lerp between it and this,
            // and this velocity to lerp between this and other (they will have different velocities)
        }
    }

    private func destroyOnEntityCollisionWith(otherEntity: Entity) -> Bool {
        entity.prev.docC != nil &&
        entity.prev.docC!.destroyOnEntityCollision &&
        !(entity.next.toxC?.safeEntities.contains(EntityRef(otherEntity)) ?? false)
    }

    // Has to be lazy otherwise we would throw on entities without a location component
    private lazy var trajectoryNextFrame: Line =
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position)

}
