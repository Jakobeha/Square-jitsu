//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct GrabSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.griC != nil {
            updateGrabbingEntity()
        }
        if entity.prev.graC != nil {
            updateGrabbableEntity()
        }
    }

    private func updateGrabbingEntity() {
        assert(entity.prev.phyC != nil)
        for otherEntity in newOverlappingEntities {
            if GrabSystem.canGrab(grabbingEntity: entity, grabbedEntity: otherEntity) {
                GrabSystem.grab(grabbingEntity: entity, grabbedEntity: otherEntity)
            }
        }
    }

    private var newOverlappingEntities: Set<Entity> {
        entity.next.phyC!.overlappingEntities.subtracting(entity.prev.phyC!.overlappingEntities)
    }

    private func updateGrabbableEntity() {
        switch entity.next.graC!.grabState {
        case .idle:
            break
        case .grabbed(grabber: let grabberRef):
            // Move with grabbing entity
            let grabber = grabberRef.deref!
            entity.next.locC!.position = grabber.next.locC!.position + grabber.next.griC!.grabOffset
        case .thrown(thrower: _):
            if entity.next.phyC?.overlappingTypes.containsSolid ?? false {
                // End throw
                entity.next.graC!.grabState = .idle
            }
        }
    }

    static func canGrab(grabbingEntity: Entity, grabbedEntity: Entity) -> Bool {
        canGrab(grabbingEntity: grabbingEntity, grabbedType: grabbingEntity.type) &&
        !(grabbedEntity.next.graC?.grabState.isGrabbed ?? false) &&
        !DamageSystem.isToxic(toxicEntity: grabbedEntity, damagedEntity: grabbingEntity)
    }

    static func canGrab(grabbingEntity: Entity, grabbedType: TileType) -> Bool {
        (grabbingEntity.next.griC?.grabbableTypes.contains(grabbedType.bigType) ?? false) &&
        (grabbingEntity.next.graC?.grabState.isIdle ?? true)
    }

    static func grab(grabbingEntity: Entity, grabbedEntity: Entity) {
        assert(
                grabbingEntity.next.griC != nil &&
                grabbedEntity.next.graC != nil &&
                canGrab(grabbingEntity: grabbingEntity, grabbedType: grabbedEntity.type)
        )
        if !canGrab(grabbingEntity: grabbingEntity, grabbedEntity: grabbedEntity) {
            Logger.warn("Entity \(grabbingEntity) will grab \(grabbedEntity) but it's not supposed to - the settings are off")
        }
        let grabbingEntityRef = EntityRef(grabbingEntity)
        let grabbedEntityRef = EntityRef(grabbedEntity)
        if !grabbingEntity.prev.griC!.grabbed.contains(grabbedEntityRef) {
            grabbingEntity.next.griC!.grabbed.append(grabbedEntityRef)
            grabbedEntity.next.graC!.grabState = .grabbed(grabber: grabbingEntityRef)
        }
    }

    static func throwNext(throwingEntity: Entity, throwDirection: Angle) {
        assert(
                throwingEntity.next.griC != nil &&
                !throwingEntity.next.griC!.grabbed.isEmpty
        )

        // Gets and removes the thrown entity from the grabbed list
        let thrownEntity = throwingEntity.next.griC!.grabbed.removeFirst().deref!

        // Mark thrown entity as thrown
        let throwingEntityRef = EntityRef(throwingEntity)
        assert(thrownEntity.next.graC!.grabState == .grabbed(grabber: throwingEntityRef))
        thrownEntity.next.graC!.grabState = .thrown(thrower: throwingEntityRef)

        // Calculate thrown entity's linear and angular velocity
        let throwSpeed = getThrowSpeed(throwingEntity: throwingEntity, thrownEntity: thrownEntity)
        let throwAngularSpeed = getThrowAngularSpeed(throwingEntity: throwingEntity, thrownEntity: thrownEntity)
        let throwVelocity = CGPoint(magnitude: throwSpeed, directionFromOrigin: throwDirection)

        // Adjust thrown entity's linear and angular velocity
        thrownEntity.next.dynC!.velocity = throwVelocity
        thrownEntity.next.dynC!.angularVelocity = throwAngularSpeed
    }

    private static func getThrowSpeed(throwingEntity: Entity, thrownEntity: Entity) -> CGFloat {
        throwingEntity.next.griC!.throwSpeed * thrownEntity.next.graC!.thrownSpeedMultiplier
    }

    private static func getThrowAngularSpeed(throwingEntity: Entity, thrownEntity: Entity) -> UnclampedAngle {
        throwingEntity.next.griC!.throwAngularSpeed * thrownEntity.next.graC!.thrownSpeedMultiplier
    }
}
