//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class WorldController {
    private struct WorldModelView {
        let world: World
        let worldView: WorldView
    }

    private var loaded: WorldModelView? = nil
    private let updater: FixedUpdater = FixedUpdater()

    init() {
        updater.onTick = tick
    }

    func loadDummyWorld() {
        load(world: World(loader: DummyWorldLoader(), settings: Settings()))
    }

    func load(world: World) {
        loaded?.worldView.remove()

        let worldView = WorldView(world: world)
        loaded = WorldModelView(world: world, worldView: worldView)
        updater.fixedDeltaTime = world.settings.fixedDeltaTime
    }

    func unload() {
        loaded?.worldView.remove()

        loaded = nil
        updater.fixedDeltaTime = CGFloat.nan
    }

    func update(_ currentTime: TimeInterval) {
        updater.update(currentTime)
    }

    private func tick() {
        loaded?.world.tick()
    }
}