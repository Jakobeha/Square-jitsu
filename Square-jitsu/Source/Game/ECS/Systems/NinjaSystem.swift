//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.next.nijC != nil {
            switch entity.prev.nijC!.actionState {
            case .idle:
                break
            case .doJump(let direction):
                tryJump(direction: direction)
                entity.next.nijC!.actionState = .idle
            case .doThrow(let direction):
                tryThrow(direction: direction)
                entity.next.nijC!.actionState = .idle
            }
            if isNearOrOnSolid {
                // Also we can jump this frame, so don't worry that this affects the next frame
                entity.next.nijC!.backgroundTypesUsed.removeAll()
            }
        }
    }

    private func tryJump(direction: Angle) {
        if canJump {
            jump(direction: direction)
        }
    }

    private func tryThrow(direction: Angle) {
        if canThrow {
            GrabSystem.throwNext(throwingEntity: entity, throwDirection: direction)
        }
    }

    private func jump(direction: Angle) {
        assert(entity.prev.nijC != nil && entity.prev.dynC != nil)
        entity.next.dynC!.velocity = CGPoint(
            magnitude: entity.prev.nijC!.jumpSpeed,
            directionFromOrigin: direction
        )
        if isNearOrOnSolid {
            // Since angular velocity would be 0 on solid,
            // to prevent infinite angular velocity from jumping near the ground
            entity.next.dynC!.angularVelocity = entity.prev.nijC!.jumpAngularSpeed
        } else {
            entity.next.dynC!.angularVelocity += entity.prev.nijC!.jumpAngularSpeed
        }
        if isNearOrOnSolid {
            entity.next.nijC!.numJumpsWithoutBackgroundRemaining = entity.next.nijC!.minNumJumpsWithoutBackground
        } else {
            // Technically this is cleared somewhere else if on solid anyways...
            entity.next.nijC!.backgroundTypesUsed.formUnion(overlappingBackgroundTypes)

            if entity.next.nijC!.numJumpsWithoutBackgroundRemaining > 0 {
                entity.next.nijC!.numJumpsWithoutBackgroundRemaining -= 1
            }
        }
    }

    private var canJump: Bool {
        isNearOrOnSolid || isOnUnusedBackground || entity.next.nijC!.numJumpsWithoutBackgroundRemaining > 0
    }

    private var canThrow: Bool {
        !(entity.next.griC?.grabbed.isEmpty ?? true)
    }

    private var isNearOrOnSolid: Bool {
        let nearTypes = entity.prev.ntlC!.nearTypes
        let onTypes = entity.prev.colC!.overlappingTypes
        return (nearTypes.contains(layer: .solid) && !onTypes.contains(layer: .toxicEdge)) || onTypes.contains(layer: .solid)
    }

    private var isOnUnusedBackground: Bool {
        let usedBackgroundTypes = entity.prev.nijC!.backgroundTypesUsed
        return !overlappingBackgroundTypes.subtracting(usedBackgroundTypes).isEmpty
    }

    private var overlappingBackgroundTypes: Set<TileType> {
        entity.prev.colC!.overlappingTypes[TileLayer.background]
    }
}
