//
// Created by Jakob Hain on 6/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class DestructibleBehavior: EmptyTileBehavior<Never> {
    var health: CGFloat = CGFloat.nan {
        didSet { _didChangeHealth.publish() }
    }

    private var _didChangeHealth: Publisher<()> = Publisher()
    var didChangeHealth: Observable<()> { Observable(publisher: _didChangeHealth) }

    override func onFirstLoad(world: World, pos: WorldTilePos3D) {
        resetHealth(world: world, pos: pos)
    }

    override func onEntityCollide(entity: Entity, pos: WorldTilePos3D) {
        if entity.next.toxC != nil {
            let myType = entity.world![pos]
            if DamageSystem.isToxic(toxicEntity: entity, damagedType: myType) {
                receiveInstantDamageFrom(entity: entity, pos3D: pos)
            }
        }
    }

    override func tick(world: World, pos: WorldTilePos3D) {
        for entity in world.entities {
            if entity.next.lilC != nil &&
               entity.next.toxC != nil &&
               entity.next.colC != nil &&
               entity.next.colC!.adjacentPositions.allElements.contains(pos.pos) {
                let myType = entity.world![pos]
                if DamageSystem.isToxic(toxicEntity: entity, damagedType: myType) {
                    receiveContinuousDamageFrom(entity: entity, pos3D: pos)
                }
            }
        }
    }

    override func revert(world: World, pos: WorldTilePos3D) {
        resetHealth(world: world, pos: pos)
    }

    private func resetHealth(world: World, pos: WorldTilePos3D) {
        let myType = world[pos]
        if let initialHealth = world.settings.destructibleSolidInitialHealth[myType] {
            health = initialHealth
        } else {
            Logger.warnSettingsAreInvalid("destructible solid has no initial health: \(myType)")
            health = 0
        }
    }

    private func receiveInstantDamageFrom(entity: Entity, pos3D: WorldTilePos3D) {
        receiveDamage(entity.next.toxC!.damage, world: entity.world!, pos3D: pos3D)
    }

    private func receiveContinuousDamageFrom(entity: Entity, pos3D: WorldTilePos3D) {
        let world = entity.world!
        let damageThisTick = entity.next.toxC!.damage * world.settings.fixedDeltaTime
        receiveDamage(damageThisTick, world: world, pos3D: pos3D)
    }

    private func receiveDamage(_ damage: CGFloat, world: World, pos3D: WorldTilePos3D) {
        health -= damage
        if health <= 0 {
            destroyTile(world: world, pos3D: pos3D)
        }
    }

    private func destroyTile(world: World, pos3D: WorldTilePos3D) {
        world.set(pos3D: pos3D, to: TileType.air, persistInGame: true)
    }
}
