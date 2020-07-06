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
            if !entity.next.toxC!.safeTypes.contains(myType) {
                receiveDamageFrom(entity: entity, pos3D: pos)
            }
        }
    }

    override func revert(world: World, pos: WorldTilePos3D) {
        resetHealth(world: world, pos: pos)
    }

    private func resetHealth(world: World, pos: WorldTilePos3D) {
        let myType = world[pos]
        let settingIndex = Int(myType.smallType.value)
        if let initialHealth = world.settings.destructibleSolidInitialHealth.getIfPresent(at: settingIndex) {
            health = initialHealth
        } else {
            Logger.warnSettingsAreInvalid("destructible solid has no initial health because its index is out of destructibleSolidInitialHealth's bounds: \(settingIndex)")
            health = 0
        }
    }

    private func receiveDamageFrom(entity: Entity, pos3D: WorldTilePos3D) {
        health -= entity.next.toxC!.damage
        if health <= 0 {
            destroyTile(world: entity.world!, pos3D: pos3D)
        }
    }

    private func destroyTile(world: World, pos3D: WorldTilePos3D) {
        world.set(pos3D: pos3D, to: TileType.air, persistInGame: true)
    }
}
