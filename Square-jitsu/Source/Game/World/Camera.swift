//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol Camera {
    var position: CGPoint { get }
    var rotation: Angle { get }
    var scale: CGFloat { get }
}

extension Camera {
    /// Applies the inverse of the camera's transform so that the node children in camera coordinates at (0, 0)
    func inverseTransform(rootNode: SKNode, settings: WorldSettings) {
        rootNode.position = (position * settings.tileViewWidthHeight / scale).rotateAroundCenter(by: -rotation)
        rootNode.angle = -rotation
        rootNode.setScale(1 / scale)
    }

    func applyTo(cameraNode: SKCameraNode, settings: WorldSettings) {
        cameraNode.position = (position * settings.tileViewWidthHeight).rounded
        cameraNode.angle = rotation
        cameraNode.setScale(scale)
    }
}
