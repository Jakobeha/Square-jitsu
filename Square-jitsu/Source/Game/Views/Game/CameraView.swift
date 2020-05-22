//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class CameraView: NodeView<SKNode> {
    var camera: Camera
    private let child: View
    private let settings: WorldSettings

    init(camera: Camera, child: View, settings: WorldSettings) {
        self.camera = camera
        self.child = child
        self.settings = settings
        super.init(node: SKNode())
        child.placeIn(parent: node)
        update()
    }

    func update() {
        camera.inverseTransform(rootNode: node, settings: settings)
    }
}
