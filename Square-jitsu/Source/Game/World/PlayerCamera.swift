//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerCamera: Camera {
    private(set) var position: CGPoint = CGPoint.zero
    private(set) var rotation: Angle = Angle.zero
    private(set) var scale: CGFloat = 1

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
