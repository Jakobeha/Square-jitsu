//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerInput {
    private struct JumpGesture {
        let touchId: ObjectIdentifier
        private var wasPerformed: Bool = false

        init(touchId: ObjectIdentifier) {
            self.touchId = touchId
        }

        mutating func tick(touch: Touch, userSettings: UserSettings, world: World) {
            assert(touch.id == touchId)
            // Once a jump gesture was performed it's only saved to prevent the touch from being reused
            if !wasPerformed {
                if touch.currentVelocity.magnitude >= userSettings.minGestureSpeedToJump {
                    let stateAtEndOfJumpGesture = touch.currentState
                    let stateAtStartOfJumpGesture = touch.getLatestStateWhenVelocityWas(atMost: userSettings.minGestureSpeedToJump) ?? touch.priorStates.first!
                    let jumpGestureOffset = stateAtEndOfJumpGesture.position - stateAtStartOfJumpGesture.position
                    let jumpGestureDistance = jumpGestureOffset.magnitude
                    if jumpGestureDistance >= userSettings.minGestureDistanceToJump {
                        let jumpGestureDirection = jumpGestureOffset.directionFromOrigin
                        perform(direction: jumpGestureDirection, world: world)
                    }
                }
            }
        }

        private mutating func perform(direction: Angle, world: World) {
            world.player.next.nijC!.jumpState = .tryingToJump(direction: direction)
            wasPerformed = true
        }
    }

    private let userSettings: UserSettings

    let tracker: TouchTracker = TouchTracker()

    private var jumpGesture: JumpGesture? = nil

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    func tick(world: World) {
        tickJumpInput(world: world)
    }

    func tickJumpInput(world: World) {
        if jumpGesture != nil {
            if let jumpTouch = tracker.touches[jumpGesture!.touchId] {
                jumpGesture!.tick(touch: jumpTouch, userSettings: userSettings, world: world)
            } else {
                jumpGesture = nil
            }
            // If there are more inputs this would be earliestTouch(where: <not used by other input>)
        } else if let jumpTouch = tracker.earliestTouch {
            jumpGesture = JumpGesture(touchId: jumpTouch.id)
            jumpGesture!.tick(touch: jumpTouch, userSettings: userSettings, world: world)
        }
    }
}
