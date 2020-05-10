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
            if isNearOrOnSolid {
                // Also we can jump this frame, so don't worry that this affects the next frame
                entity.next.nijC!.backgroundTypesUsed.removeAll()
            }
        }
    }

    func tryToJump(direction: Angle) {
        if canJump {
            jump(direction: direction)
        } else {
            print("Failed")
        }
    }

    func jump(direction: Angle) {
        assert(entity.prev.nijC != nil && entity.prev.dynC != nil)
        entity.next.dynC!.velocity = CGPoint(
            magnitude: entity.prev.nijC!.jumpSpeed,
            directionFromOrigin: direction
        )
        if isNearOrOnSolid {
            // Since angular velocity would be 0 on solid,
            // to prevent infinite angular velocity from jumping near the ground
            entity.next.dynC!.angularVelocity = entity.prev.nijC!.jumpAngularVelocity
        } else {
            entity.next.dynC!.angularVelocity += entity.prev.nijC!.jumpAngularVelocity
        }
        // Technically this is cleared somewhere else if on solid anyways...
        if !isNearOrOnSolid {
            entity.next.nijC!.backgroundTypesUsed.formUnion(overlappingBackgroundTypes)
        }
    }

    var canJump: Bool {
        assert(entity.prev.nijC != nil && entity.prev.ntlC != nil && entity.prev.phyC != nil)
        return isNearOrOnSolid || isOnUnusedBackground
    }

    var isNearOrOnSolid: Bool {
        let nearTypes = entity.prev.ntlC!.nearTypes
        let onTypes = entity.prev.phyC!.overlappingTypes
        return (nearTypes.contains(layer: TileLayer.solid) && !onTypes.contains(layer: TileLayer.toxic)) || onTypes.contains(layer: TileLayer.solid)
    }

    var isOnUnusedBackground: Bool {
        let usedBackgroundTypes = entity.prev.nijC!.backgroundTypesUsed
        return !overlappingBackgroundTypes.subtracting(usedBackgroundTypes).isEmpty
    }

    var overlappingBackgroundTypes: Set<TileType> {
        entity.prev.phyC!.overlappingTypes[TileLayer.background]
    }
}
