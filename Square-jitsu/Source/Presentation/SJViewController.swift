//
//  GameViewController.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/2/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class SJViewController: UIViewController {
    private var scene: EditorScene! = nil
    private var started: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView

        // Configure view
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true

        // Create the scene
        scene = EditorScene(size: view.bounds.size)
        scene.viewController = self
        scene.scaleMode = .resizeFill

        // Present the scene
        view.presentScene(scene)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // if start is put in viewDidLoad and the start mode is supposed to display the level picker,
        // it won't display for some reason
        start()
    }

    private func start() {
        assert(!started)
        started = true

        let startMode = SJStartMode(ProcessInfo.processInfo.environment["START_MODE"]) ?? SJStartMode.default

        switch startMode {
        case .editorTestWorld:
            loadTestWorld()
        case .editorLevelSelection:
            presentLevelPicker(animated: false)
        }
    }

    private func loadTestWorld() {
        scene.beginGameSession {
            self.presentLevelPicker(animated: true)
        }
        scene.editorController.loadTestWorld()
    }

    private func presentLevelPicker(animated: Bool) {
        let levelPicker = try! LevelPickerViewController.new(initialUrl: WorldFile.rootDirectoryUrl, canCancel: false) { pickedUrl in
            self.scene.beginGameSession {
                self.presentLevelPicker(animated: true)
            }
            self.scene.editorController.load(worldUrl: pickedUrl) { result in
                switch result {
                case .failure(let error):
                    let errorAlert = UIAlertController(title: "Failed to load world", message: error.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Continue", style: .default))
                    // Want to try to keep the level picker visible
                    self.presentLevelPicker(animated: false)
                    self.present(errorAlert, animated: true)
                case .success(()):
                    break
                }
            }
        }
        present(levelPicker, animated: false)
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override var prefersStatusBarHidden: Bool { true }
}
