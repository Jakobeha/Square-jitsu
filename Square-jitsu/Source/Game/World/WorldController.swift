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

    private let userSettings: UserSettings
    private let parent: SKNode
    private let updater: FixedUpdater = FixedUpdater()
    private(set) var loaded: WorldModelView? = nil
    var isPaused: Bool = false

    init(userSettings: UserSettings, parent: SKNode) {
        self.userSettings = userSettings
        self.parent = parent
        updater.onTick = tick
    }

    func loadDummyWorld() {
        load(world: World(
            loader: DummyWorldLoader(),
            settings: WorldSettingsManager.default,
            userSettings: userSettings,
            conduit: nil
        ))
    }

    func load(world: World) {
        unload()

        fatalError("TODO: Add gloss mask node")

        /*let worldView = WorldView(world: world, glossMaskNode: <#TODO#>)
        worldView.placeIn(parent: parent)
        loaded = WorldModelView(world: world, worldView: worldView)
        updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
        world.didChangeSpeed.subscribe(observer: self, priority: .model) {
            self.updater.fixedDeltaTime = world.settings.fixedDeltaTime / world.speed
            self.parent.speed = world.speed
        }*/
    }

    func unload() {
        loaded?.world.didChangeSpeed.unsubscribe(observer: self)
        loaded?.worldView.removeFromParent()

        loaded = nil
        updater.fixedDeltaTime = CGFloat.nan
    }

    /// Even if paused we still need to update to prevent accumulated ticks
    func update(_ currentTime: TimeInterval) {
        updater.update(currentTime)
    }

    private func tick() {
        if !isPaused {
            loaded?.world.tick()
        }
    }
}
