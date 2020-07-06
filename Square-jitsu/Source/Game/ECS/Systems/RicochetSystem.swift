//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct RicochetSystem: SubCollisionSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    mutating func handleOverlappingCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {}

    mutating func handleSolidCollisionWith(tileType: TileType, tilePosition: WorldTilePos, side: Side) {
        if entity.next.ricC != nil {
            bounceOffOfIfNecessary(side: side)
        }
    }

    mutating func handleCollisionWith(entity otherEntity: Entity) {}

    private func bounceOffOfIfNecessary(side: Side) {
        let speedInDirection = CGPoint.dot(entity.next.dynC!.velocity, side.perpendicularOffset.toCgPoint)
        if speedInDirection > 0 {
            bounceOffOf(side: side, speedInDirection: speedInDirection)
        }
    }

    private func bounceOffOf(side: Side, speedInDirection: CGFloat) {
        print("Bounce")

        // Increment num bounces and check if we need to destroy this
        entity.next.ricC!.numBouncesSoFar += 1
        // Using == instead of > means that
        // if numBouncesBeforeDestroy is 0 this will never be destroyed (as intended)
        // (also if this was already destroyed (actually applied next frame) but bounces again
        //  it won't be destroyed twice, although technically this is handled so it would be ok)
        if entity.next.ricC!.numBouncesSoFar == entity.next.ricC!.numBouncesBeforeDestroy {
            world.remove(entity: entity)
        }

        // Actually bounce (change velocity)
        let velocityInDirection = side.perpendicularOffset.toCgPoint * speedInDirection
        entity.next.dynC!.velocity -= velocityInDirection * (1 + entity.next.ricC!.bounceMultiplier)
    }

    private var newAdjacentSides: SideSet {
        entity.next.colC!.adjacentSides.subtracting(entity.prev.colC!.adjacentSides)
    }
}
