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
        if entity.prev.colC != nil {
            // All of the solid overlapping tiles should be adjacent (not checked though),
            // and they might have extra side requirements (e.g. lava only occurs on some tile sides)
            handleOverlappingNotSolidTiles()
            handleAdjacentTiles()
            handleEntities()
        }
        if !(entity.prev.helC?.isAlive ?? true) {
            killEntity()
        }
    }

    func handleOverlappingNotSolidTiles() {
        // Otherwise we don't need to handle tiles
        if entity.prev.helC != nil {
            for tilePosition in newOverlappingTilePositions {
                let tileTypes = world[tilePosition]
                for tileType in tileTypes {
                    if !tileType.isSolid {
                        handleOverlappingNotSolid(tileType: tileType, tilePosition: tilePosition)
                    }
                }
            }
        }
    }

    func handleAdjacentTiles() {
        // Otherwise we don't need to handle tiles
        if entity.prev.helC != nil {
            for (side, tilePositions) in newAdjacentTilePositions {
                for tilePosition in tilePositions {
                    let tileTypes = world[tilePosition]
                    for tileType in tileTypes {
                        handleAdjacent(tileType: tileType, tilePosition: tilePosition, side: side)
                    }
                }
            }
        }
    }

    func handleEntities() {
        // We need to handle other entities even if this one doesn't have health,
        // because this one might be toxic and they might have health
        if entity.prev.helC != nil || entity.prev.toxC != nil {
            for otherEntity in newOverlappingEntities {
                handle(entity: otherEntity)
            }
        }
    }

    func killEntity() {
        // Death animations, etc. are on remove
        world.remove(entity: entity)
    }

    func handleOverlappingNotSolid(tileType: TileType, tilePosition: WorldTilePos) {
        if DamageSystem.isToxic(toxicType: tileType, damagedEntity: entity) {
            DamageSystem.damage(toxicType: tileType, damagedEntity: entity)
        }
    }

    func handleAdjacent(tileType: TileType, tilePosition: WorldTilePos, side: Side) {
        if DamageSystem.isToxic(toxicType: tileType, toxicSide: side, damagedEntity: entity) {
            DamageSystem.damage(toxicType: tileType, damagedEntity: entity)
        }
    }

    func handle(entity otherEntity: Entity) {
        // We need to check if other toxic entities collided with this entity,
        // because either of the entities might not be physical
        if DamageSystem.isToxic(toxicEntity: otherEntity, damagedEntity: entity) {
            DamageSystem.damage(toxicEntity: otherEntity, damagedEntity: entity)
        } else if DamageSystem.isToxic(toxicEntity: entity, damagedEntity: otherEntity) {
            DamageSystem.damage(toxicEntity: entity, damagedEntity: otherEntity)
        }
    }

    private var newOverlappingTilePositions: Set<WorldTilePos> {
        Set(entity.next.colC!.overlappingPositions).subtracting(entity.prev.colC!.overlappingPositions)
    }

    private var newAdjacentTilePositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        DenseEnumMap { side in
            entity.next.colC!.adjacentPositions[side].subtracting(entity.prev.colC!.adjacentPositions[side])
        }
    }

    private var newOverlappingEntities: Set<Entity> {
        Set(entity.next.colC!.overlappingEntities).subtracting(entity.prev.colC!.overlappingEntities)
    }

    // region exposed methods
    static func isToxic(toxicType: TileType, toxicSide: Side, damagedEntity: Entity) -> Bool {
        isToxic(toxicType: toxicType, damagedEntity: damagedEntity) &&
        toxicType.existsAt(side: toxicSide, orientationMeaning: damagedEntity.world!.settings.tileOrientationMeanings[toxicType] ?? .unused)
    }

    static func isToxic(toxicType: TileType, damagedEntity: Entity) -> Bool {
        damagedEntity.prev.helC != nil &&
        (damagedEntity.world!.settings.tileDamage[toxicType] ?? 0) != 0
    }

    static func isToxic(toxicEntity: Entity, damagedEntity: Entity) -> Bool {
        toxicEntity.prev.toxC != nil &&
        damagedEntity.prev.helC != nil &&
        !toxicEntity.next.toxC!.safeTypes.contains(damagedEntity.type) &&
        !toxicEntity.next.toxC!.safeEntities.contains(EntityRef(damagedEntity)) &&
        toxicEntity.next.graC?.grabState.grabbedOrThrownBy != damagedEntity
    }

    static func damage(toxicType: TileType, damagedEntity: Entity) {
        assert(isToxic(toxicType: toxicType, damagedEntity: damagedEntity))
        let damage = damagedEntity.world!.settings.tileDamage[toxicType]!
        damagedEntity.next.helC!.health -= damage
    }

    static func damage(toxicEntity: Entity, damagedEntity: Entity) {
        assert(isToxic(toxicEntity: toxicEntity, damagedEntity: damagedEntity))
        damagedEntity.next.helC!.health -= toxicEntity.prev.toxC!.damage
    }
    // endregion
}
