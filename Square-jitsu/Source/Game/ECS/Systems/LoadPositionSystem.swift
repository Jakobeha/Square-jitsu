//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LoadPositionSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {
        resetEntityBoundingBoxes(world: world)
    }

    func tick() {
        if entity.next.locC != nil {
            if entity.next.larC != nil {
                world.loadAround(pos: entity.next.locC!.position)
                extendLoadAroundEntityBoundingBox(world: world, entityBounds: entity.next.locC!.bounds)
            } else {
                world.load(pos: entity.next.locC!.position)
                extendEntityBoundingBox(world: world, entityBounds: entity.next.locC!.bounds)
            }
        }
    }

    static func postTick(world: World) {
        world.unloadUnnecessaryChunks()
    }

    static func resetEntityBoundingBoxes(world: World) {
        world.boundingBoxToPreventUnload = CGRect.null
    }

    func extendLoadAroundEntityBoundingBox(world: World, entityBounds: CGRect) {
        let boundsToPreventUnload = entityBounds.insetBy(
                sideLength: -(CGFloat(Chunk.widthHeight) + Chunk.extraDistanceFromEntityToUnload)
        )
        world.boundingBoxToPreventUnload = world.boundingBoxToPreventUnload.union(boundsToPreventUnload)
    }

    func extendEntityBoundingBox(world: World, entityBounds: CGRect) {
        let boundsToPreventUnload = entityBounds.insetBy(sideLength: -Chunk.extraDistanceFromEntityToUnload)
        world.boundingBoxToPreventUnload = world.boundingBoxToPreventUnload.union(boundsToPreventUnload)
    }
}
