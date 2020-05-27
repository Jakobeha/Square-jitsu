//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Camera {
    var position: CGPoint = CGPoint.zero {
        didSet { _didChange.publish() }
    }
    var rotation: Angle = Angle.zero {
        didSet { _didChange.publish() }
    }
    var scale: CGFloat = 1 {
        didSet { _didChange.publish() }
    }

    private let _didChange: Publisher<()> = Publisher()
    var didChange: Observable<()> { Observable(publisher: _didChange) }

    /// Applies the camera's transform to convert the point from screen coordinates to camera coordinates
    func transform(position: CGPoint, settings: WorldSettings) -> CGPoint {
        (position / settings.tileViewWidthHeight * scale).rotateAroundCenter(by: rotation) + self.position
    }

    /// Applies the inverse of the camera's transform to convert the point from camera coordinates to screen coordinates
    func inverseTransform(position: CGPoint, settings: WorldSettings) -> CGPoint {
        (position - self.position).rotateAroundCenter(by: -rotation) * settings.tileViewWidthHeight / scale
    }

    /// Applies the inverse of the camera's transform so that the node children in camera coordinates at (0, 0)
    func inverseTransformUX(rootNode: SKNode, size: CGSize, settings: WorldSettings) {
        let sizeOffset = CGPoint(x: size.width, y: -size.height)
        rootNode.position = inverseTransform(position: CGPoint.zero, settings: settings) + (sizeOffset / 2)
        rootNode.angle = -rotation
        rootNode.setScale(1 / scale)    }

        /// Applies the inverse of the camera's transform so that the node children in camera coordinates at (0, 0)
    func inverseTransform(rootNode: SKNode, size: CGSize, settings: WorldSettings) {
        rootNode.position = inverseTransform(position: CGPoint.zero, settings: settings) + (size / 2)
        rootNode.angle = -rotation
        rootNode.setScale(1 / scale)
    }

    func applyTo(cameraNode: SKCameraNode, settings: WorldSettings) {
        cameraNode.position = (position * settings.tileViewWidthHeight).rounded
        cameraNode.angle = rotation
        cameraNode.setScale(scale)
    }
}
