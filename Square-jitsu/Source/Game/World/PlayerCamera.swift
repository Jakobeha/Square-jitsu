//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerCamera: Camera {
    /// Position without shake effect
    private var perfectPosition: CGPoint = CGPoint.zero
    private var shake: CGFloat = 0

    private var shakeRng: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    private var currentShakeOffset: CGPoint = CGPoint.zero
    private var nextShakeOffset: CGPoint = CGPoint.zero

    func tick(world: World) {
        updatePerfectPosition(world: world)
        updateShake(world: world)
        updatePosition()
    }

    private func updatePerfectPosition(world: World) {
        let settings = world.settings
        let player = world.player

        perfectPosition = CGPoint.lerp(
                start: perfectPosition,
                end: player.prev.locC!.position,
                t: settings.cameraSpeed
        )
    }

    private func updateShake(world: World) {
        let settings = world.settings

        if shake > 0 {
            if (nextShakeOffset - currentShakeOffset).magnitude <= settings.shakeInterpolationDistanceBeforeChange {
                nextShakeOffset = CGPoint(magnitude: shake, directionFromOrigin: Angle.random(using: &shakeRng))
            }

            currentShakeOffset = CGPoint.lerp(start: currentShakeOffset, end: nextShakeOffset, t: settings.shakeInterpolationFractionPerFrame)
        } else {
            currentShakeOffset = CGPoint.zero
            nextShakeOffset = CGPoint.zero
        }

        shake = max(0, shake - (settings.shakeFade * settings.fixedDeltaTime))
    }

    private func updatePosition() {
        position = perfectPosition + currentShakeOffset
    }

    func add(shake newShake: CGFloat) {
        shake += newShake
    }
}
