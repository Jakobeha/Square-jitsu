//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TouchTracker {
    private(set) var touches: [ObjectIdentifier:Touch] = [:]

    var earliestTouch: Touch? {
        touches.values.min { lhsTouch, rhsTouch in
            lhsTouch.startTimestamp < rhsTouch.startTimestamp
        }
    }

    private let _didUpdateTouches: Publisher<()> = Publisher()
    var didUpdateTouches: Observable<()> { Observable(publisher: _didUpdateTouches) }

    func touchesBegan(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        touchesUpdated(uiTouches, with: event, container: container)
    }

    func touchesMoved(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        touchesUpdated(uiTouches, with: event, container: container)
    }

    func touchesEnded(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        touchesUpdated(uiTouches, with: event, container: container)
    }

    func touchesCancelled(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        touchesUpdated(uiTouches, with: event, container: container)
    }

    func reset() {
        touches.removeAll()
    }

    private func touchesUpdated(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        updateTouchesBeforeNotifyingObservers(uiTouches, with: event, container: container)
        _didUpdateTouches.publish()
        removeEndedTouches()
    }

    private func updateTouchesBeforeNotifyingObservers(_ uiTouches: Set<UITouch>, with event: UIEvent?, container: SKNode) {
        for uiTouch in uiTouches {
            switch uiTouch.phase {
            case .began, .regionEntered:
                addTouch(uiTouch: uiTouch, container: container)
            case .moved, .stationary, .regionMoved:
                if var touch = touches[uiTouch.id] {
                    touch.updateFrom(uiTouch: uiTouch, container: container)
                    touch.phase = .intermediate
                    touches[uiTouch.id] = touch
                } else {
                    addTouch(uiTouch: uiTouch, container: container)
                }
            case .ended, .regionExited:
                if var touch = touches[uiTouch.id] {
                    touch.updateFrom(uiTouch: uiTouch, container: container)
                    touch.phase = .ended
                    touches[uiTouch.id] = touch
                }
            case .cancelled:
                if var touch = touches[uiTouch.id] {
                    touch.phase = .ended
                    touches[uiTouch.id] = touch
                }
            @unknown default:
                fatalError("unhandled touch phase")
            }
        }
    }

    private func addTouch(uiTouch: UITouch, container: SKNode) {
        let touch = Touch(uiTouch: uiTouch, container: container)
        touches[uiTouch.id] = touch
    }

    private func removeEndedTouches() {
        for (touchId, touch) in touches {
            if touch.phase == .ended {
                touches[touchId] = nil
            }
        }
    }
}
