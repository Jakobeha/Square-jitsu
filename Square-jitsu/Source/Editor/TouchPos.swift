//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TouchPos {
    static func getPositionDelta(uiTouch: UITouch, container: SKScene) -> CGPoint {
        getPosition(uiTouch: uiTouch, container: container) - getPreviousPosition(uiTouch: uiTouch, container: container)
    }

    static func getPosition(uiTouch: UITouch, container: SKScene) -> CGPoint {
        let position = uiTouch.location(in: container.view!)
        return convertPositionFromViewCoordsToSceneCoords(position: position, container: container)
    }

    private static func getPreviousPosition(uiTouch: UITouch, container: SKScene) -> CGPoint {
        let position = uiTouch.previousLocation(in: container.view!)
        return convertPositionFromViewCoordsToSceneCoords(position: position, container: container)
    }

    private static func convertPositionFromViewCoordsToSceneCoords(position: CGPoint, container: SKScene) -> CGPoint {
        CGPoint(
            x: position.x - container.size.width / 2,
            y: (container.size.height / 2) - position.y
        )
    }

    let screenPos: CGPoint
    let worldScreenPos: CGPoint
    let worldTilePos: WorldTilePos
    /// Change in world position since last touch event
    let worldPosDelta: CGPoint

    init(uiTouch: UITouch, camera: Camera, settings: WorldSettings, container: SKScene) {
        screenPos = TouchPos.getPosition(uiTouch: uiTouch, container: container)
        worldScreenPos = camera.transform(position: screenPos)
        worldTilePos = WorldTilePos.closestTo(pos: worldScreenPos)

        let prevScreenPos = TouchPos.getPreviousPosition(uiTouch: uiTouch, container: container)
        let screenPosDelta = screenPos - prevScreenPos
        worldPosDelta = screenPosDelta / settings.tileViewWidthHeight
    }
}
