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
    private let sceneSize: CGSize
    private let settings: WorldSettings

    init(camera: Camera, child: View, sceneSize: CGSize, settings: WorldSettings) {
        self.camera = camera
        self.child = child
        self.sceneSize = sceneSize
        self.settings = settings
        super.init(node: SKNode())
        child.placeIn(parent: node)
        update()
        camera.didChange.subscribe(observer: self, handler: update)
    }

    private func update() {
        camera.inverseTransform(rootNode: node, size: sceneSize, settings: settings)
    }
}
