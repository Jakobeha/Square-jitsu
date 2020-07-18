//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class OverlayContainer {
    private(set) var overlays: [Overlay] = []

    private let _didPresentOverlay: Publisher<()> = Publisher()
    private let _didDismissOverlay: Publisher<Int> = Publisher()
    var didPresentOverlay: Observable<()> { Observable(publisher: _didPresentOverlay) }
    var didDismissOverlay: Observable<Int> { Observable(publisher: _didDismissOverlay) }

    var preventTouchPropagation: Bool {
        overlays.contains { overlays in overlays.preventTouchPropagation }
    }

    func present(_ overlay: Overlay) {
        overlays.append(overlay)
        overlay.didPresentIn(container: self)
        _didPresentOverlay.publish()
    }

    func dismiss(_ overlay: Overlay) {
        guard let overlayIndex = overlays.firstIndex(where: { anOverlay in
            overlay === anOverlay
        }) else {
            fatalError("tried to dismiss overlay which isn't in the container: \(overlay)")
        }

        overlays.remove(at: overlayIndex)
        _didDismissOverlay.publish(overlayIndex)
    }

    // region touch forwarding
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        for element in overlays.reversed() {
            element.touchesBegan(touches, with: event, container: container)
            if element.preventTouchPropagation {
                break
            }
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        for element in overlays.reversed() {
            element.touchesMoved(touches, with: event, container: container)
            if element.preventTouchPropagation {
                break
            }
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        for element in overlays.reversed() {
            element.touchesEnded(touches, with: event, container: container)
            if element.preventTouchPropagation {
                break
            }
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        for element in overlays.reversed() {
            element.touchesCancelled(touches, with: event, container: container)
            if element.preventTouchPropagation {
                break
            }
        }
    }
    // endregion
}
