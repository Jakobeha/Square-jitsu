//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TouchPos {
    static func getPosition(uiTouch: UITouch, container: SKScene) -> CGPoint {
        var position = uiTouch.location(in: container.view!)
        position.y *= -1
        return position
    }

    let screenPos: CGPoint
    let worldScreenPos: CGPoint
    let worldTilePos: WorldTilePos

    init(uiTouch: UITouch, camera: Camera, settings: WorldSettings, container: SKScene) {
        screenPos = TouchPos.getPosition(uiTouch: uiTouch, container: container)
        worldScreenPos = camera.transform(position: screenPos, settings: settings)
        worldTilePos = WorldTilePos.closestTo(pos: worldScreenPos)
    }
}
