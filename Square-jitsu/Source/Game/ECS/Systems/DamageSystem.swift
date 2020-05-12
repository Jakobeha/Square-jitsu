//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct DamageSystem: System {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.prev.phyC != nil {
            for otherEntity in newOverlappingEntities {
                // We need to check if other toxic entities collided with this entity,
                // because either of the entities might not be physical
                if DamageSystem.isToxic(toxicEntity: otherEntity, damagedEntity: entity) {
                    DamageSystem.damage(toxicEntity: otherEntity, damagedEntity: entity)
                } else if DamageSystem.isToxic(toxicEntity: entity, damagedEntity: otherEntity) {
                    DamageSystem.damage(toxicEntity: entity, damagedEntity: otherEntity)
                }
            }
        }
        if !(entity.prev.helC?.isAlive ?? true) {
            killEntity()
        }
    }

    func killEntity() {
        // Death animations, etc. are on remove
        world.remove(entity: entity)
    }

    private var newOverlappingEntities: Set<Entity> {
        entity.next.phyC!.overlappingEntities.subtracting(entity.prev.phyC!.overlappingEntities)
    }

    static func isToxic(toxicEntity: Entity, damagedEntity: Entity) -> Bool {
        toxicEntity.prev.toxC != nil &&
        damagedEntity.prev.helC != nil &&
        !toxicEntity.prev.toxC!.safeTypes.contains(damagedEntity.type) &&
        !toxicEntity.prev.toxC!.safeEntities.contains(EntityRef(damagedEntity)) &&
        !(toxicEntity.next.toxC!.onlyToxicIfThrown && (toxicEntity.next.graC?.grabState.isThrown ?? false)) &&
        toxicEntity.next.graC?.grabState.grabbedOrThrownBy != damagedEntity
    }

    static func damage(toxicEntity: Entity, damagedEntity: Entity) {
        assert(isToxic(toxicEntity: toxicEntity, damagedEntity: damagedEntity))
        damagedEntity.next.helC!.health -= toxicEntity.prev.toxC!.damage
    }
}
