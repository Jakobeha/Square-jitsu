//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CameraView: NodeView<SKNode> {
    var camera: Camera {
        willSet {
            camera.didChange.unsubscribe(observer: self)
        }
        didSet {
            update()
            camera.didChange.subscribe(observer: self, handler: update)
        }
    }
    private let child: View

    init(camera: Camera, child: View) {
        self.camera = camera
        self.child = child
        super.init(node: SKNode())
        child.placeIn(parent: node)
        update()
        camera.didChange.subscribe(observer: self, handler: update)
    }

    private func update() {
        camera.inverseTransform(rootNode: node)
    }
}
