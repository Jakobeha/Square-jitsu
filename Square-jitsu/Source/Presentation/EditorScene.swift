//
//  GameScene.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorScene: SKScene {
    private let settings: UserSettings = UserSettings()

    private var editorController: EditorController? {
        willSet {
            if editorController != nil {
                fatalError("worldController shouldn't be set twice")
            }
        }
    }

    private var loadedEditor: Editor? {
        editorController?.loaded?.editor
    }

    private var loadedWorld: World? {
        editorController?.loaded?.world
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()

        editorController = EditorController(userSettings: UserSettings(), parent: self)
        editorController!.loadTestWorld()
    }

    override func update(_ currentTime: TimeInterval) {
        editorController?.update(currentTime)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let loadedEditor = loadedEditor {
            switch loadedEditor.state {
            case .playing:
                loadedEditor.editableWorld.world.playerInput.tracker.touchesBegan(touches, with: event, container: self)
            case .editing:
                // TODO
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let loadedEditor = loadedEditor {
            switch loadedEditor.state {
            case .playing:
                loadedEditor.editableWorld.world.playerInput.tracker.touchesMoved(touches, with: event, container: self)
            case .editing:
                // TODO
                break
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let loadedEditor = loadedEditor {
            switch loadedEditor.state {
            case .playing:
                loadedEditor.editableWorld.world.playerInput.tracker.touchesEnded(touches, with: event, container: self)
            case .editing:
                // TODO
                break
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if let loadedEditor = loadedEditor {
            switch loadedEditor.state {
            case .playing:
                loadedEditor.editableWorld.world.playerInput.tracker.touchesCancelled(touches, with: event, container: self)
            case .editing:
                // TODO
                break
            }
        }
    }
}
