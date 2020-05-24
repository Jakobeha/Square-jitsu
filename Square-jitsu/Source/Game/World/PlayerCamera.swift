//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerCamera: Camera {
    func tick(world: World) {
        let settings = world.settings
        let player = world.player

        position = CGPoint.lerp(
                start: position,
                end: player.prev.locC!.position,
                t: settings.cameraSpeed
        )
    }
}
