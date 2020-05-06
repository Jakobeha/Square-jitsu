//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    private let worldController: WorldController = WorldController()

    override func sceneDidLoad() {
        super.sceneDidLoad()
        worldController.loadDummyWorld()
    }

    override func update(_ currentTime: TimeInterval) {
        worldController.update(currentTime)
    }
}
