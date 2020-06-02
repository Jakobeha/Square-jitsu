//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerInput {
    private struct PrimarySwipe {
        let touchId: ObjectIdentifier
        private var wasPerformed: Bool = false

        init(touchId: ObjectIdentifier) {
            self.touchId = touchId
        }

        mutating func tick(touch: Touch, userSettings: UserSettings, world: World) {
            assert(touch.id == touchId)
            // Once a swipe was performed it's only saved to prevent the touch from being reused
            if !wasPerformed {
                if touch.currentVelocity.magnitude >= userSettings.minPrimarySwipeSpeed {
                    let stateAtEndOfPrimarySwipe = touch.currentState
                    let stateAtStartOfPrimarySwipe = touch.getLatestStateWhenVelocityWas(atMost: userSettings.minPrimarySwipeSpeed) ?? touch.priorStates.first!
                    let primarySwipeOffset = stateAtEndOfPrimarySwipe.position - stateAtStartOfPrimarySwipe.position
                    let primarySwipeDistance = primarySwipeOffset.magnitude
                    if primarySwipeDistance >= userSettings.minPrimarySwipeDistance {
                        let primarySwipeDirection = primarySwipeOffset.directionFromOrigin
                        perform(direction: primarySwipeDirection, world: world)
                    }
                }
            }
        }

        private mutating func perform(direction: Angle, world: World) {
            world.player.next.nijC!.actionState = .doPrimary(direction: direction)
            wasPerformed = true
        }
    }

    weak var world: World!
    private let userSettings: UserSettings

    let tracker: TouchTracker = TouchTracker()

    private var primarySwipe: PrimarySwipe? = nil

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        tracker.didUpdateTouches.subscribe(observer: self, priority: .input, handler: tick)
    }

    func tick() {
        tickPrimary()
    }

    func tickPrimary() {
        if primarySwipe != nil {
            if let primaryTouch = tracker.touches[primarySwipe!.touchId] {
                primarySwipe!.tick(touch: primaryTouch, userSettings: userSettings, world: world)
            } else {
                primarySwipe = nil
            }
            // If there are more inputs this would be earliestTouch(where: <not used by other input>)
        } else if let primaryTouch = tracker.earliestTouch {
            primarySwipe = PrimarySwipe(touchId: primaryTouch.id)
            primarySwipe!.tick(touch: primaryTouch, userSettings: userSettings, world: world)
        }
    }
}
