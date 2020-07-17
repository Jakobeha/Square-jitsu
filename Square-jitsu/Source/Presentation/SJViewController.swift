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

        guard let startModeString = ProcessInfo.processInfo.environment["START_MODE"] else {
            fatalError("no start mode")
        }
        guard let startMode = SJStartMode(startModeString) else {
            fatalError("invalid start mode: \(startModeString)")
        }

        switch startMode {
        case .editorTestWorld:
            scene.editorController.loadTestWorld()
        case .editorLevelSelection:
            let levelPicker = try! LevelPickerViewController.new(initialUrl: WorldFile.rootDirectoryUrl, canCancel: false) { pickedUrl in
                self.scene.editorController.load(worldUrl: pickedUrl) { result in
                    switch result {
                    case .failure(let error):
                        fatalError("failed to load initial world: \(error.localizedDescription)")
                    case .success(()):
                        break
                    }
                }
            }
            present(levelPicker, animated: false)
        }
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override var prefersStatusBarHidden: Bool { true }
}
