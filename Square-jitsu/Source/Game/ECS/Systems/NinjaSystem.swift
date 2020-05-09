//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    func tick() {
        if entity.prev.nijC != nil {
            switch entity.prev.nijC!.jumpState {
            case .idle:
                break
            case .tryingToJump(let direction):
                tryToJump(direction: direction)
                entity.next.nijC!.jumpState = .idle
            }
            if entity.prev.phyC!.isOnSolid {
                // Also we can jump this frame, so don't worry that this affects the next frame
                entity.next.nijC!.backgroundTypesUsed.removeAll()
            }
        }
    }

    func tryToJump(direction: Angle) {
        if canJump {
            jump(direction: direction)
        }
    }

    func jump(direction: Angle) {
        assert(entity.prev.nijC != nil && entity.prev.dynC != nil)
        entity.next.dynC!.velocity = CGPoint(
            magnitude: entity.prev.nijC!.jumpSpeed,
            directionFromOrigin: direction
        )
        entity.next.dynC!.angularVelocity += entity.prev.nijC!.jumpAngularVelocity
        // Technically this is cleared somewhere else if on solid anyways...
        if !entity.prev.phyC!.isOnSolid {
            entity.next.nijC!.backgroundTypesUsed.formUnion(overlappingBackgroundTypes)
        }
    }

    var canJump: Bool {
        assert(entity.prev.nijC != nil && entity.prev.phyC != nil)
        return entity.prev.phyC!.isOnSolid || isOnUnusedBackground
    }

    var isOnUnusedBackground: Bool {
        let usedBackgroundTypes = entity.prev.nijC!.backgroundTypesUsed
        return !overlappingBackgroundTypes.subtracting(usedBackgroundTypes).isEmpty
    }

    var overlappingBackgroundTypes: Set<TileSmallType> {
        entity.prev.phyC!.overlappingTypes.smallTypesFor(bigType: TileBigType.background)
    }
}
