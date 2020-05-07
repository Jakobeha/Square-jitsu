//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class WorldController {
    struct WorldModelView {
        let world: World
        let worldView: WorldView
    }

    private let parent: SKNode
    private let updater: FixedUpdater = FixedUpdater()
    private(set) var loaded: WorldModelView? = nil

    init(parent: SKNode) {
        self.parent = parent
        updater.onTick = tick
    }

    func loadDummyWorld() {
        load(world: World(loader: DummyWorldLoader(), settings: Settings()))
    }

    func load(world: World) {
        loaded?.worldView.removeFromParent()

        let worldView = WorldView(world: world)
        worldView.placeIn(parent: parent)
        loaded = WorldModelView(world: world, worldView: worldView)
        updater.fixedDeltaTime = world.settings.fixedDeltaTime
    }

    func unload() {
        loaded?.worldView.removeFromParent()

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
