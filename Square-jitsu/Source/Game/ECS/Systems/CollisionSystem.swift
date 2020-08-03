//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct CollisionSystem: EarlyTopLevelSystem {
    let entity: Entity

    var subCollisionSystems: [SubCollisionSystem]

    init(entity: Entity) {
        self.entity = entity

        subCollisionSystems = SubCollisionSystems.map { subCollisionSystemClass in
            subCollisionSystemClass.init(entity: entity)
        }
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    var isRunningOnSpawn: Bool = false

    mutating func tickOnSpawn() {
        isRunningOnSpawn = true
        tick()
    }

    mutating func tick() {
        preResetCollisions()
        if handlesTileCollisions {
            handleTileCollisions()
        }
        if handlesEntityCollisions {
            handleEntityCollisions()
        }
        postResetCollisions()
    }

    private func preResetCollisions() {
        entity.next.colC?.preReset()
    }

    private func postResetCollisions() {
        entity.next.colC?.postReset()
    }

    private var handlesTileCollisions: Bool {
        ((entity.prev.docC != nil && entity.prev.docC!.destroyOnSolidCollision) || entity.prev.colC != nil) &&
                !(entity.next.graC?.grabState.isGrabbed ?? false)
    }

    private var handlesEntityCollisions: Bool {
        ((entity.prev.docC != nil && entity.prev.docC!.destroyOnEntityCollision) || entity.prev.colC != nil) &&
                !(entity.next.graC?.grabState.isGrabbed ?? false)
    }

    private mutating func handleTileCollisions() {
        assert(handlesTileCollisions)
        if entity.prev.locC != nil {
            handleTileCollisionsWithLocation()
        } else if entity.prev.lilC != nil {
            handleTileCollisionsWithLineLocation()
        } else {
            fatalError("illegal state - no location or line location component")
        }
    }

    // region location component collision detection
    private mutating func handleTileCollisionsWithLocation() {
        for tilePosition in trajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: entity.prev.locC!.radius) {
            for layer in 0..<Chunk.numLayers {
                let pos3D = WorldTilePos3D(pos: tilePosition, layer: layer)
                let pos3DAfterFillers = world.followFillersAt(pos3D: pos3D)
                let tileType = world[pos3DAfterFillers]

                handleCollisionWith(tileType: tileType, pos3D: pos3D)
                if entityBlockedFromFurtherCollisions {
                    return // blocked by other collisions
                }
            }
        }
    }

    private mutating func handleCollisionWith(tileType: TileType, pos3D: WorldTilePos3D) {
        let tilePosition = pos3D.pos

        // Insert into overlapping types
        if entity.prev.colC != nil {
            entity.next.colC!.overlappingTypes.insert(tileType)
            let isFirstAtPosition = pos3D.layer == 0
            if isFirstAtPosition {
                assert(!entity.next.colC!.overlappingPositions.contains(tilePosition))
                entity.next.colC!.overlappingPositions.append(tilePosition)
            }
        }

        // Handle sub-systems
        for index in subCollisionSystems.indices {
            subCollisionSystems[index].handleOverlappingCollisionWith(tileType: tileType, tilePosition: tilePosition)
        }

        // Handle if solid
        if tileType.isSolid {
            handleSolidCollisionWith(tileType: tileType, pos3D: pos3D)
        }

        // Notify metadatas if this is a new collision
        if !collidedOnLastFrameWith(tileType: tileType) {
            let pos3DAfterFillers = world.followFillersAt(pos3D: pos3D)
            if let tileBehavior = world.getBehaviorAt(pos3D: pos3DAfterFillers) {
                tileBehavior.onEntityCollide(entity: entity, pos: pos3DAfterFillers)
            }
        }
    }

    private func collidedOnLastFrameWith(tileType: TileType) -> Bool {
        (entity.prev.colC?.overlappingTypes.contains(type: tileType) ?? false) ||
        (entity.prev.docC?.isRemoved ?? false)
    }

    private mutating func handleSolidCollisionWith(tileType: TileType, pos3D: WorldTilePos3D) {
        let tilePosition = pos3D.pos
        if !isRunningOnSpawn && entity.prev.docC?.destroyOnSolidCollision ?? false {
            world.remove(entity: entity)
            entity.next.docC!.isRemoved = true
        }
        if entity.prev.colC != nil {
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
                handleCollisionWith(tileType: tileType, pos3D: pos3D, side: parallelSide)
            } else if let hitAxis = calculateCollidedAxis(
                    trajectoryNextFrame: trajectoryNextFrame,
                    xIsLeft: xIsLeft,
                    yIsBottom: yIsBottom,
                    xBarrier: xBarrier,
                    yBarrier: yBarrier,
                    tilePosition: tilePosition
            ) {
                // Necessary so we don't override velocity - technically we collide this frame but we won't the next
                let side: Side! = CollisionSystem.getSide(axis: hitAxis, xIsLeft: xIsLeft, yIsBottom: yIsBottom)

                handleCollisionWith(tileType: tileType, pos3D: pos3D, side: side)
            }
        }
    }

    private mutating func handleCollisionWith(tileType: TileType, pos3D: WorldTilePos3D, side: Side) {
        // Check if the tile actually exists at this side
        if tileType.occupiedSides.contains(side.opposite.toSet) {
            let tilePosition = pos3D.pos

            entity.next.colC!.adjacentSides.insert(side.toSet)
            entity.next.colC!.adjacentPositions.append(key: side, pos3D.pos)

            // Handle sub-systems
            for index in subCollisionSystems.indices {
                subCollisionSystems[index].handleSolidCollisionWith(tileType: tileType, tilePosition: tilePosition, side: side)
            }

            // Notify metadatas if this is a new collision at this (2D) position
            if !collidedOnLastFrameWith(tileType: tileType) {
                let pos3DAfterFillers = world.followFillersAt(pos3D: pos3D)
                if let tileBehavior = world.getBehaviorAt(pos3D: pos3DAfterFillers) {
                    tileBehavior.onEntitySolidCollide(entity: entity, pos: pos3DAfterFillers, side: side)
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

    private func calculateCollidedAxis(trajectoryNextFrame: LineSegment, xIsLeft: Bool, yIsBottom: Bool, xBarrier: CGFloat, yBarrier: CGFloat, tilePosition: WorldTilePos) -> Axis? {
        let timeToXBarrier = trajectoryNextFrame.tAt(x: xBarrier)
        let timeToYBarrier = trajectoryNextFrame.tAt(y: yBarrier)
        let neverHitXBarrier = timeToXBarrier == nil
        let neverHitYBarrier = timeToYBarrier == nil
        let xSide = xIsLeft ? Side.west : Side.east
        let ySide = yIsBottom ? Side.south : Side.north
        let adjacentXPosition = tilePosition + xSide.perpendicularOffset
        let adjacentYPosition = tilePosition + ySide.perpendicularOffset
        let adjacentXIsBlocked = world[adjacentXPosition].contains { type in type.isSolid }
        let adjacentYIsBlocked = world[adjacentYPosition].contains { type in type.isSolid }
        let adjacentSides = entity.next.colC!.adjacentSides
        let collidedWithXEarlierInTrajectory = adjacentSides.contains(xSide.toSet)
        let collidedWithYEarlierInTrajectory = adjacentSides.contains(ySide.toSet)
        let xIsImpossible = collidedWithXEarlierInTrajectory || adjacentXIsBlocked || neverHitXBarrier
        let yIsImpossible = collidedWithYEarlierInTrajectory || adjacentYIsBlocked || neverHitYBarrier
        switch (xIsImpossible, yIsImpossible) {
        case (false, false):
            // If we hit a corner it's technically ambiguous.
            // We choose whichever axis is hit last and ignore the other
            return (timeToXBarrier! > timeToYBarrier!) ? .horizontal : .vertical
        case (true, false):
            return .vertical
        case (false, true):
            return .horizontal
        case (true, true):
            // This is inside of a corner (unless physics is broken) so we didn't actually hit it
            return nil
        }
    }

    private static func getSide(axis: Axis, xIsLeft: Bool, yIsBottom: Bool) -> Side {
        switch axis {
        case .horizontal:
            // We hit from the x axis
            // Add side, move out of solid, cancel velocity
            return xIsLeft ? Side.east : Side.west
        case .vertical:
            // We hit from the y axis
            // Add side, move out of solid, cancel velocity
            return yIsBottom ? Side.north : Side.south
        }
    }

    private static func entitiesShouldCollide(_ lhs: Entity, _ rhs: Entity) -> Bool {
        entitiesShouldCollide1Way(lhs, rhs) && entitiesShouldCollide1Way(rhs, lhs)
    }

    private static func entitiesShouldCollide1Way(_ lhs: Entity, _ rhs: Entity) -> Bool {
        !(lhs.next.graC?.grabState.isGrabbed ?? false) &&
        lhs.prev.graC?.grabState.grabbedOrThrownBy != rhs &&
        (lhs.prev.graC?.grabState.grabbedOrThrownBy == nil ||
         lhs.prev.graC?.grabState.grabbedOrThrownBy != rhs.prev.graC?.grabState.grabbedOrThrownBy)
    }

    private func destroyOnEntityCollisionWith(otherEntity: Entity) -> Bool {
        entity.next.docC != nil &&
        entity.next.docC!.destroyOnEntityCollision &&
        !entity.next.docC!.ignoredTypes.contains(otherEntity.type) &&
        !entity.next.docC!.ignoredEntities.contains(EntityRef(otherEntity))
    }
    // endregion

    // region line location component collision detection

    // Currently we only use the next line location,
    // instead of a trajectory from prev to next,
    // because the latter is too complicated and unnecessary.

    private mutating func handleTileCollisionsWithLineLocation() {
        entity.next.colC!.overlappingPositions = getLineLocationOverlappingPositions()
        entity.next.colC!.adjacentPositions = lineLocationAdjacentPositions
        entity.next.colC!.adjacentSides = getLineLocationAdjacentSides()
    }
    
    private mutating func getLineLocationOverlappingPositions() -> [WorldTilePos] {
        trajectoryNextFrame.capsuleCastTilePositions(capsuleRadius: entity.next.lilC!.thickness)
    }

    private lazy var lineLocationAdjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> = DenseEnumMap { side in
        var adjacentPositionsForSide: Set<WorldTilePos> = []
        if let startEndpointHit = entity.next.lilC!.startEndpointHit,
           startEndpointHit.hitSide == side {
            adjacentPositionsForSide.insert(startEndpointHit.pos3D.pos)
        }
        if let endEndpointHit = entity.next.lilC!.endEndpointHit,
           endEndpointHit.hitSide == side {
            adjacentPositionsForSide.insert(endEndpointHit.pos3D.pos)
        }
        return adjacentPositionsForSide
    }

    private mutating func getLineLocationAdjacentSides() -> SideSet {
        SideSet(lineLocationAdjacentPositions.mapValues {
            positions in !positions.isEmpty
        })
    }
    // endregion

    // region entity collision detection shared between location and line location components
    private mutating func handleEntityCollisions() {
        let entityCollisions = world.entities.compactMap { otherEntity in
            if entity == otherEntity || !CollisionSystem.entitiesShouldCollide(entity, otherEntity) {
                // Entity can't collide with itself, or entities shouldn't collide
                return nil
            } else if otherEntity.worldIndex < entity.worldIndex,
                      let fractionUntilCollision = entity.next.colC?.earlyOverlappingEntities.first(where: { (fractionUntilCollision, earlyOverlappingEntity) in
                otherEntity == earlyOverlappingEntity
            }).map({ (fractionUntilCollision, earlyOverlappingEntity) in
                fractionUntilCollision
            }) {
                // The other entity collided and is giving us our fraction
                // (this ensures that if A collides with B, B collides with A)
                return (fractionUntilCollision, otherEntity)
            } else if CollisionSystem.doesEntityHaveLocation(entity: otherEntity) {
                let otherEntityTrajectory = CollisionSystem.getTrajectoryOf(entity: otherEntity)
                let radiusForIntersection = radiusOrThickness + CollisionSystem.getRadiusOrThicknessOf(entity: otherEntity)
                if let (fractionUntilCollision, otherEntityFractionUntilCollision) = trajectoryNextFrame.capsuleCastIntersection(capsuleRadius: radiusForIntersection, otherLine: otherEntityTrajectory) {
                    otherEntity.next.colC?.earlyOverlappingEntities.append((otherEntityFractionUntilCollision, entity))
                    return (fractionUntilCollision, otherEntity)
                } else {
                    // There was no collision
                    return nil
                }
            } else {
                // Can't collide (no position)
                return nil
            }
        }.sorted { ($0 as (CGFloat, Entity)).0 < $1.0 }
        
        // Handle collisions on this entity's trajectory
        for (fractionUntilCollision, otherEntity) in entityCollisions {
            handleCollisionWith(entity: otherEntity, fractionOnTrajectory: fractionUntilCollision)
        }
    }

    private mutating func handleCollisionWith(entity otherEntity: Entity, fractionOnTrajectory: CGFloat) {
        // Destroy if necessary
        if !isRunningOnSpawn && destroyOnEntityCollisionWith(otherEntity: otherEntity) {
            world.remove(entity: entity)
            entity.next.docC!.isRemoved = true
        }

        // Insert into overlapping entities
        if entity.prev.colC != nil {
            entity.next.colC!.overlappingEntities.append(otherEntity)
        }

        // Handle sub-systems
        for index in subCollisionSystems.indices {
            subCollisionSystems[index].handleCollisionWith(entity: otherEntity)
        }
    }
    // endregion

    // region misc shared computations
    // Has to be lazy otherwise we would throw on entities without a location component
    private lazy var trajectoryNextFrame: LineSegment = CollisionSystem.getTrajectoryOf(entity: entity)

    private var radiusOrThickness: CGFloat { CollisionSystem.getRadiusOrThicknessOf(entity: entity) }

    private static func doesEntityHaveLocation(entity: Entity) -> Bool {
        entity.next.locC != nil || entity.next.lilC != nil
    }

    private static func getTrajectoryOf(entity: Entity) -> LineSegment {
        if entity.next.locC != nil {
            return entity.prev.locC!.position.isNaN ?
                    LineSegment(start: entity.next.locC!.position, end: entity.next.locC!.position) :
                    LineSegment(start: entity.prev.locC!.position, end: entity.next.locC!.position)
        } else if entity.next.lilC != nil {
            return entity.next.lilC!.position
        } else {
            fatalError("illegal state - no location component (locC or lilC) on entity")
        }
    }

    private static func getRadiusOrThicknessOf(entity: Entity) -> CGFloat {
        if entity.next.locC != nil {
            return entity.next.locC!.radius
        } else if entity.next.lilC != nil {
            return entity.next.lilC!.thickness
        } else {
            fatalError("illegal state - no location component (locC or lilC) on entity")
        }
    }
    // endregion
}
