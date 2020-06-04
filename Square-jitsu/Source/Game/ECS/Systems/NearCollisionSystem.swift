//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NearCollisionSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    mutating func tick() {
        resetNearCollisions()
        if handlesNearTileCollisions {
            handleNearTileCollisions()
        }
    }

    private func resetNearCollisions() {
        if entity.next.ntlC != nil {
            entity.next.ntlC!.reset()
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

    private var handlesNearTileCollisions: Bool {
        entity.prev.ntlC != nil
    }

    private mutating func handleNearCollisionWith(tileType: TileType, tilePosition: WorldTilePos) {
        assert(entity.prev.ntlC != nil)
        entity.next.ntlC!.nearTypes.insert(tileType)
    }

    // Same definition as CollisionSystem#trajectoryNextFrame but it's calculated after next entity position might change
    private lazy var nearTrajectoryNextFrame: Line =
        entity.prev.locC!.position.isNaN ?
        Line(start: entity.next.locC!.position, end: entity.next.locC!.position) :
        Line(start: entity.prev.locC!.position, end: entity.next.locC!.position)

}
