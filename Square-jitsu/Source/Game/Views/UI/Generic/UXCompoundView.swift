//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UXCompoundView: View, UXView {
    private var body: UXView! = nil {
        didSet {
            // Otherwise is first set
            if oldValue != nil {
                body.topLeft = oldValue.topLeft
                if let oldParent = oldValue.parent {
                    oldValue.removeFromParent()
                    body.placeIn(parent: oldParent)
                }
            }
        }
    }

    override init() {
        super.init()
        body = newBody()
    }

    func newBody() -> UXView {
        fatalError("newBody is abstract - must subclass and override")
    }

    var topLeft: CGPoint {
        get { body.topLeft }
        set { body.topLeft = newValue }
    }

    var size: CGSize {
        body.size
    }

    final func regenerateBody() {
        body = newBody()
    }

    final override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        body.placeIn(parent: parent)
    }

    final override func removeFromParent() {
        super.removeFromParent()
        body.removeFromParent()
    }
}
