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
    var userSettings: UserSettings {
        didSet { _didChange.publish() }
    }
    weak var world: World? = nil {
        willSet { world?.didReset.unsubscribe(observer: self) }
        didSet { world?.didReset.subscribe(observer: self, priority: ObservablePriority.model, handler: loadVisibleChunks) }
    }

    var screenSize: CGSize {
        userSettings.screenSize
    }
    var sizeInWorldCoords: CGSize {
        screenSize / world!.settings.tileViewWidthHeight * scale
    }
    var boundsInWorldCoords: CGRect {
        CGRect(center: position, size: sizeInWorldCoords).rotateBoundsBy(rotation)
    }

    private let _didChange: Publisher<()> = Publisher()
    var didChange: Observable<()> { Observable(publisher: _didChange) }

    init(userSettings: UserSettings) {
        self.userSettings = userSettings

        didChange.subscribe(observer: self, priority: ObservablePriority.model, handler: loadVisibleChunks)
    }

    private func loadVisibleChunks() {
        world?.load(rect: boundsInWorldCoords)
    }

    /// Applies the camera's transform to convert the point from screen coordinates to camera coordinates
    func transform(position: CGPoint) -> CGPoint {
        (position / world!.settings.tileViewWidthHeight * scale).rotateAroundCenter(by: rotation) + self.position
    }

    /// Applies the inverse of the camera's transform to convert the point from camera coordinates to screen coordinates
    func inverseTransform(position: CGPoint) -> CGPoint {
        (position - self.position).rotateAroundCenter(by: -rotation) * world!.settings.tileViewWidthHeight / scale
    }

    /// Applies the inverse of the camera's transform so that the node children in camera coordinates at (0, 0)
    func inverseTransformUX(rootNode: SKNode) {
        let screenSizeOffset = CGPoint(x: screenSize.width, y: -screenSize.height)
        rootNode.position = inverseTransform(position: CGPoint.zero) + (screenSizeOffset / 2)
        rootNode.angle = -rotation
        rootNode.setScale(1 / scale)    }

        /// Applies the inverse of the camera's transform so that the node children in camera coordinates at (0, 0)
    func inverseTransform(rootNode: SKNode) {
        rootNode.position = inverseTransform(position: CGPoint.zero) + (screenSize / 2)
        rootNode.angle = -rotation
        rootNode.setScale(1 / scale)
    }

    func applyTo(cameraNode: SKCameraNode, settings: WorldSettings) {
        cameraNode.position = (position * settings.tileViewWidthHeight).rounded
        cameraNode.angle = rotation
        cameraNode.setScale(scale)
    }
}
