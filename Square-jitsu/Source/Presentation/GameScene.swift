//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class GameScene: SJScene {
    private let settings: UserSettings = UserSettings()
    override var size: CGSize {
        didSet { settings.screenSize = size }
    }

    private var worldController: WorldController? {
        willSet {
            if worldController != nil {
                fatalError("worldController shouldn't be set twice")
            }
        }
    }

    private var loadedWorld: World? {
        worldController?.loaded?.world
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
        settings.screenSize = size

        worldController = WorldController(userSettings: settings, parent: self)
        worldController!.loadDummyWorld()

        let cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
    }

    override func update(_ currentTime: TimeInterval) {
        worldController?.update(currentTime)
        if !isPaused {
            if let loadedWorld = loadedWorld,
               let cameraNode = camera {
                loadedWorld.playerCamera.applyTo(cameraNode: cameraNode)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isPaused {
            loadedWorld?.playerInput.tracker.touchesBegan(touches, with: event, container: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if !isPaused {
            loadedWorld?.playerInput.tracker.touchesMoved(touches, with: event, container: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if !isPaused {
            loadedWorld?.playerInput.tracker.touchesEnded(touches, with: event, container: self)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if !isPaused {
            loadedWorld?.playerInput.tracker.touchesCancelled(touches, with: event, container: self)
        }
    }
}
