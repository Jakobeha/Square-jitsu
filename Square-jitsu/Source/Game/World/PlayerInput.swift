//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerInput {
    private class Swipe: Equatable {
        static func ==(lhs: Swipe, rhs: Swipe) -> Bool {
            lhs.touchId == rhs.touchId
        }

        let touchId: ObjectIdentifier
        private weak var playerInput: PlayerInput!
        var wasPerformed: Bool = false

        init(touchId: ObjectIdentifier, playerInput: PlayerInput) {
            self.touchId = touchId
            self.playerInput = playerInput
        }

        func tick(touch: Touch) {
            assert(touch.id == touchId)
            // Once a swipe was performed it's only saved to prevent the touch from being reused
            if !wasPerformed {
                if touch.currentVelocity.magnitude >= playerInput.userSettings.minPrimarySwipeSpeed {
                    let stateAtEndOfPrimarySwipe = touch.currentState
                    let stateAtStartOfPrimarySwipe = touch.getLatestStateWhenVelocityWas(atMost: playerInput.userSettings.minPrimarySwipeSpeed) ?? touch.priorStates.first!
                    let primarySwipeOffset = stateAtEndOfPrimarySwipe.position - stateAtStartOfPrimarySwipe.position
                    let primarySwipeDistance = primarySwipeOffset.magnitude
                    if primarySwipeDistance >= playerInput.userSettings.minPrimarySwipeDistance {
                        let primarySwipeDirection = primarySwipeOffset.directionFromOrigin
                        playerInput.performPrimary(swipe: self, direction: primarySwipeDirection)
                    }
                }
            }
        }
    }

    weak var world: World!

    private let userSettings: UserSettings
    let tracker: TouchTracker = TouchTracker()

    private var swipes: [ObjectIdentifier:Swipe] = [:]
    // Have a variable e.g. weaponSwipe if we implement weapons,
    // so only one swipe can do that

    var totalNumTouches: Int {
        swipes.count
    }

    var removedTouchIds: Set<ObjectIdentifier> {
        Set(swipes.keys).subtracting(tracker.touches.keys)
    }
    var addedTouchIds: Set<ObjectIdentifier> {
        Set(tracker.touches.keys).subtracting(swipes.keys)
    }
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        tracker.didUpdateTouches.subscribe(observer: self, priority: .input, handler: tick)
    }

    func tick() {
        tickSwipes()
        updateWorldSpeed()
    }

    private func tickSwipes() {
        for touchId in removedTouchIds {
            swipes[touchId] = nil
        }
        for touchId in addedTouchIds {
            swipes[touchId] = Swipe(touchId: touchId, playerInput: self)
        }
        for (touchId, touch) in tracker.touches {
            swipes[touchId]!.tick(touch: touch)
        }
    }

    private func updateWorldSpeed() {
        world.playerInputSpeedMultiplier = swipes.count == 0 ? 1 : world.settings.playerInputSpeedMultiplier
    }

    private func performPrimary(swipe: Swipe, direction: Angle) {
        assert(swipes.values.contains(swipe))

        world.player.next.nijC!.actionState = getPrimaryActionState(direction: direction)
        swipe.wasPerformed = true
    }

    private func getPrimaryActionState(direction: Angle) -> NinjaComponent.ActionState {
        switch totalNumTouches {
        case 0:
            fatalError("illegal state - getPrimaryActionState called with 0 touches but it should at least have 1 (the primary touch)")
        case 1:
            return .doJump(direction: direction)
        case 2:
            return .doThrow(direction: direction)
        default:
            return .idle
        }
    }
}
