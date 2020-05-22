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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView

        // Configure view
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true

        // Create the scene
        let scene = EditorScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill

        // Present the scene
        view.presentScene(scene)
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override var prefersStatusBarHidden: Bool { true }
}
