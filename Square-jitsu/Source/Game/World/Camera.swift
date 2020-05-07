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
    func applyTo(cameraNode: SKCameraNode, settings: Settings) {
        cameraNode.position = position * settings.tileViewWidthHeight
        cameraNode.zRotation = CGFloat(rotation.radians)
        cameraNode.setScale(scale)
    }
}
