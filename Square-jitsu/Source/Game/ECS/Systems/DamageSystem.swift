//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct DamageSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.next.colC != nil {
            // All of the solid overlapping tiles should be adjacent (not checked though),
            // and they might have extra side requirements (e.g. lava only occurs on some tile sides)
            handleOverlappingNotSolidTiles()
            handleAdjacentTiles()
            handleEntities()
        }
        if !(entity.next.helC?.isAlive ?? true) {
            killEntity()
        }
    }

    func handleOverlappingNotSolidTiles() {
        // Otherwise we don't need to handle tiles
        if entity.next.helC != nil {
            for tileType in newOverlappingTileTypes {
                handleOverlappingNotSolid(tileType: tileType)
            }
        }
    }

    func handleAdjacentTiles() {
        // Otherwise we don't need to handle tiles
        if entity.next.helC != nil {
            for (side, tileTypes) in newAdjacentTileTypes {
                for tileType in tileTypes {
                    handleAdjacent(tileType: tileType, side: side)
                }
            }
        }
    }

    func handleEntities() {
        // We need to handle other entities even if this one doesn't have health,
        // because this one might be toxic and they might have health
        if entity.next.helC != nil || entity.next.toxC != nil {
            for otherEntity in newOverlappingEntities {
                handle(entity: otherEntity)
            }
        }
    }

    func killEntity() {
        // Death animations, etc. are on remove
        world.remove(entity: entity)
    }

    func handleOverlappingNotSolid(tileType: TileType) {
        if DamageSystem.isToxic(toxicType: tileType, damagedEntity: entity) {
            DamageSystem.damage(toxicType: tileType, damagedEntity: entity)
        }
    }

    func handleAdjacent(tileType: TileType, side: Side) {
        if DamageSystem.isToxic(toxicType: tileType, toxicSide: side, damagedEntity: entity) {
            DamageSystem.damage(toxicType: tileType, damagedEntity: entity)
        }
    }

    func handle(entity otherEntity: Entity) {
        if DamageSystem.isToxic(toxicEntity: otherEntity, damagedEntity: entity) {
            DamageSystem.damage(toxicEntity: otherEntity, damagedEntity: entity)
        }
    }

    private var newOverlappingTileTypes: Set<TileType> {
        getTypesAt(positions: entity.next.colC!.overlappingPositions).subtracting(getTypesAt(positions: entity.prev.colC!.overlappingPositions)).subtracting(newAdjacentTileTypes.allElements)
    }

    private var newAdjacentTileTypes: DenseEnumMap<Side, Set<TileType>> {
        DenseEnumMap { side in
            getTypesAt(positions: entity.next.colC!.adjacentPositions[side]).subtracting(getTypesAt(positions: entity.prev.colC!.adjacentPositions[side]))
        }
    }

    private var newOverlappingEntities: Set<Entity> {
        Set(entity.next.colC!.overlappingEntities).subtracting(entity.prev.colC!.overlappingEntities)
    }

    private func getTypesAt<WorldTilePosCollection: Collection>(positions: WorldTilePosCollection) -> Set<TileType> where WorldTilePosCollection.Element == WorldTilePos {
        Set(positions.flatMap { position in world[position] })
    }

    // region exposed methods
    static func isToxic(toxicType: TileType, toxicSide: Side, damagedEntity: Entity) -> Bool {
        isToxic(toxicType: toxicType, damagedEntity: damagedEntity) &&
        toxicType.occupiedSides.contains(toxicSide.toSet)
    }

    static func isToxic(toxicType: TileType, damagedEntity: Entity) -> Bool {
        damagedEntity.prev.helC != nil &&
        (damagedEntity.world!.settings.tileDamage[toxicType] ?? 0) != 0
    }

    static func isToxic(toxicEntity: Entity, damagedEntity: Entity) -> Bool {
        toxicEntity.next.toxC != nil &&
        damagedEntity.next.helC != nil &&
        !toxicEntity.next.toxC!.safeTypes.contains(damagedEntity.type) &&
        !toxicEntity.next.toxC!.safeEntities.contains(EntityRef(damagedEntity)) &&
        toxicEntity.next.graC?.grabState.grabbedOrThrownBy != damagedEntity
    }

    static func isToxic(toxicEntity: Entity, damagedType: TileType) -> Bool {
        toxicEntity.next.toxC != nil &&
        toxicEntity.next.toxC!.affectsDestructibleTiles &&
        !toxicEntity.next.toxC!.safeTypes.contains(damagedType)
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
