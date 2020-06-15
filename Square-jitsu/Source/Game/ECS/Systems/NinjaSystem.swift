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
        if entity.prev.nijC != nil {
            switch entity.prev.nijC!.actionState {
            case .idle:
                break
            case .doPrimary(let direction):
                doPrimary(direction: direction)
                entity.next.nijC!.actionState = .idle
            }
            if isNearOrOnSolid {
                // Also we can jump this frame, so don't worry that this affects the next frame
                entity.next.nijC!.backgroundTypesUsed.removeAll()
            }
        }
    }

    func doPrimary(direction: Angle) {
        switch primaryAction {
        case .none:
            break
        case .jump:
            jump(direction: direction)
        case .throw:
            GrabSystem.throwNext(throwingEntity: entity, throwDirection: direction)
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
            entity.next.dynC!.angularVelocity = entity.prev.nijC!.jumpAngularSpeed
        } else {
            entity.next.dynC!.angularVelocity += entity.prev.nijC!.jumpAngularSpeed
        }
        // Technically this is cleared somewhere else if on solid anyways...
        if !isNearOrOnSolid {
            entity.next.nijC!.backgroundTypesUsed.formUnion(overlappingBackgroundTypes)
        }
    }

    var primaryAction: NinjaPrimaryAction {
        assert(entity.prev.nijC != nil && entity.prev.ntlC != nil && entity.prev.colC != nil)
        if isNearOrOnSolid {
            return .jump
        } else if canThrow {
            return .throw
        } else if isOnUnusedBackground {
            return .jump
        } else {
            return .none
        }
    }

    var isNearOrOnSolid: Bool {
        let nearTypes = entity.prev.ntlC!.nearTypes
        let onTypes = entity.prev.colC!.overlappingTypes
        return (nearTypes.contains(layer: .solid) && !onTypes.contains(layer: .toxicEdge)) || onTypes.contains(layer: .solid)
    }

    var canThrow: Bool {
        !(entity.next.griC?.grabbed.isEmpty ?? true)
    }

    var isOnUnusedBackground: Bool {
        let usedBackgroundTypes = entity.prev.nijC!.backgroundTypesUsed
        return !overlappingBackgroundTypes.subtracting(usedBackgroundTypes).isEmpty
    }

    var overlappingBackgroundTypes: Set<TileType> {
        entity.prev.colC!.overlappingTypes[TileLayer.background]
    }
}
