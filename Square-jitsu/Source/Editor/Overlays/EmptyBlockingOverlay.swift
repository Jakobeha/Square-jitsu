//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EmptyBlockingOverlay: Overlay {
    var preventTouchPropagation: Bool { true }

    private weak var container: OverlayContainer? = nil

    func didPresentIn(container: OverlayContainer) {
        assert(self.container == nil, "overlay is already presented in another container")
        self.container = container
    }

    func dismissIfVisible() {
        container?.dismiss(self)
    }

    // region touch handling
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {}

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {}

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {}

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {}
    // endregion
}
