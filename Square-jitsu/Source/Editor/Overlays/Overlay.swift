//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol Overlay: AnyObject {
    var preventTouchPropagation: Bool { get }

    func didPresentIn(container: OverlayContainer)
    func dismissIfVisible()

    // region touch handling
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene)
    // endregion
}
