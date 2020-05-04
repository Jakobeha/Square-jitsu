//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CollidingEntity: DynamicEntity {
    override init(position: CGPoint, rotation: Angle = Angle.zero, radius: CGFloat = 0.5) {
        super.init(position: position, rotation: rotation, radius: radius)
    }

    func tickPhysics() {
        if (world != nil) {
            if (handlesTileCollisions) {
                handleTileCollisions()
            }
            if (handlesEntityCollisions) {
                handleEntityCollisions()
            }
        }
    }

    private func handleTileCollisions() {
        assert(world != nil && handlesTileCollisions)
        for tilePosition in trajectoryNextFrame.capsuleCastTilePositions() {
            let tile = world![tilePosition]
            if (collidesWith(tile: tile)) {
                handleCollisionWith(tile: tile, tilePosition: tilePosition)
                break // blocked by other collisions
            }
        }
    }

    private func handleEntityCollisions() {
        assert(world != nil && handlesEntityCollisions)
        let entityCollisions = world!.entities.compactMap { entity in
            let radiusForIntersection = radius + entity.radius
            let fractionUntilCollision = trajectoryNextFrame.capsuleCastIntersection(capsuleRadius: radiusForIntersection, point: entity.position)
            if Float.isNan(fractionUntilCollision) {
                // There was no collision
                return nil
            } else {
                return (fractionUntilCollision, entity)
            }
        }.sorted { $0.0 < $1.0 }
        for (fractionUntilCollision, entity) in entityCollisions {
            handleCollisionWith(entity: entity, fractionOnTrajectory: fractionUntilCollision)
        }
    }

    private func collidesWith(tile: Tile) -> Bool {
        switch tile.type.bigType {
        case .solid, .ice:
            return true
        case .air, .background, .shurikenSpawn, .enemySpawn, .playerSpawn:
            return false
        }
    }

    // region collision handling interface
    var handlesTileCollisions: Bool { false }
    var handlesEntityCollisions: Bool { false }

    func handleCollisionWith(tile: Tile, tilePosition: WorldTilePos) {
        // overridden by subclasses
    }
    
    func handleCollisionWith(entity: Entity, fractionOnTrajectory: CGFloat) {
        // overridden by subclasses
    }
    // endregion
}
