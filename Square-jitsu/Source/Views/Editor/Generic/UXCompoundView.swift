//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UXCompoundView: UXView {
    private var body: UXView! = nil

    final var node: SKNode { body.node }

    var size: CGSize { body.size }

    private(set) weak var scene: SJScene? = nil {
        didSet {
            if let scene = scene {
                body?.set(scene: scene)
            }
        }
    }

    init() {
        body = newBody()
    }

    func newBody() -> UXView {
        fatalError("newBody is abstract - must subclass and override")
    }

    final func regenerateBody() {
        let oldTopLeft = body.topLeft
        let oldZPosition = body.zPosition
        let oldParent = body.node.parent

        // body may already be set
        body.set(parent: nil)
        body = newBody()

        body.topLeft = oldTopLeft
        body.zPosition = oldZPosition
        body.set(parent: oldParent)
        if let scene = scene {
            body.set(scene: scene)
        }
    }

    final func set(scene: SJScene) {
        self.scene = scene
    }
}
