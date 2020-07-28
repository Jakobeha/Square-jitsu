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

    mutating func tick() {
        if entity.next.nijC != nil {
            switch entity.next.nijC!.actionState {
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

    private mutating func tryJump(direction: Angle) {
        if canJump(direction: direction) {
            jump(direction: direction)
        }
    }

    private func tryThrow(direction: Angle) {
        if canThrow {
            GrabSystem.throwNext(throwingEntity: entity, throwDirection: direction)
        }
    }

    private mutating func jump(direction: Angle) {
        assert(entity.prev.nijC != nil && entity.prev.dynC != nil)

        // If jumping off a solid, move away so a sideways jump would work
        for side in Side.allCases {
            if entity.next.colC!.adjacentSides.contains(side.toSet) && !entity.next.colC!.adjacentSides.contains(side.opposite.toSet) {
                entity.next.locC!.position -= side.perpendicularOffset.toCgPoint * NinjaComponent.jumpOffSolidInstantDistance
            }
        }

        // Set velocity
        let actualJumpDirection = getActualJumpDirection(intendedDirection: direction)
        entity.next.dynC!.velocity = CGPoint(
            magnitude: entity.prev.nijC!.jumpSpeed,
            directionFromOrigin: actualJumpDirection
        )

        // Set angular velocity
        if isNearOrOnSolid {
            // Since angular velocity would be 0 on solid,
            // to prevent infinite angular velocity from jumping near the ground
            entity.next.dynC!.angularVelocity = entity.prev.nijC!.jumpAngularSpeed
        } else {
            entity.next.dynC!.angularVelocity += entity.prev.nijC!.jumpAngularSpeed
        }

        // Mark # of background jumps remaining, and background types used,
        // to prevent excessive jumps
        if isNearOrOnSolid {
            entity.next.nijC!.backgroundTypesUsed.removeAll()
            entity.next.nijC!.numJumpsWithoutBackgroundRemaining = entity.next.nijC!.minNumJumpsWithoutBackground
        } else {
            // Technically this is cleared somewhere else if on solid anyways...
            entity.next.nijC!.backgroundTypesUsed = overlappingBackgroundTypes

            if entity.next.nijC!.numJumpsWithoutBackgroundRemaining > 0 {
                entity.next.nijC!.numJumpsWithoutBackgroundRemaining -= 1
            }
        }
    }

    private mutating func getActualJumpDirection(intendedDirection: Angle) -> Angle {
        overriddenJumpDirections.isEmpty ? intendedDirection : overriddenJumpDirections.first { overriddenJumpDirection in
            let offsetFromDirection = overriddenJumpDirection - intendedDirection
            return offsetFromDirection.isAbsoluteSmallerThan(angle: NinjaComponent.maxOffsetFromOverriddenDirectionForJumpToStillOccur)
        }!
    }

    private mutating func canJump(direction: Angle) -> Bool {
        canJumpInAnyDirection && couldJumpInSpecificDirection(direction: direction)
    }

    private mutating func couldJumpInSpecificDirection(direction: Angle) -> Bool {
        overriddenJumpDirections.isEmpty ? true : overriddenJumpDirections.contains { overriddenJumpDirection in
            let offsetFromDirection = overriddenJumpDirection - direction
            return offsetFromDirection.isAbsoluteSmallerThan(angle: NinjaComponent.maxOffsetFromOverriddenDirectionForJumpToStillOccur)
        }
    }

    static func canEntityJumpInAnyDirection(entity: Entity) -> Bool {
        assert(entity.next.nijC != nil, "canEntityJumpInAnyDirection called on entity which isn't a ninja (no nijC)")
        return NinjaSystem(entity: entity).canJumpInAnyDirection
    }

    private var canJumpInAnyDirection: Bool {
        isNearOrOnSolid || isOnUnusedBackground || entity.next.nijC!.numJumpsWithoutBackgroundRemaining > 0
    }

    private var canThrow: Bool {
        !(entity.next.griC?.grabbed.isEmpty ?? true)
    }

    private var isNearOrOnSolid: Bool {
        let nearTypes = entity.prev.ntlC!.nearTypes
        let onTypes = entity.prev.colC!.overlappingTypes
        return
            ((nearTypes.contains(layer: .solid) || nearTypes.contains(bigType: .solidEdge)) && !onTypes.contains(bigType: .lava)) ||
            (onTypes.contains(layer: .solid) || onTypes.contains(bigType: .solidEdge))
    }

    private var isOnUnusedBackground: Bool {
        let usedBackgroundTypes = entity.prev.nijC!.backgroundTypesUsed
        return !overlappingBackgroundTypes.subtracting(usedBackgroundTypes).isEmpty
    }

    private var overlappingBackgroundTypes: Set<TileType> {
        entity.prev.colC!.overlappingTypes[.background]
    }

    private lazy var overriddenJumpDirections: [Angle] = {
        entity.next.colC!.overlappingTypes.getOrientationsWith(bigType: .backgroundDirectionBoost).map { orientation in
            orientation.asCorner.directionFromCenter
        }
    }()
}
