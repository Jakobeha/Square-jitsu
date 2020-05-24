//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Wraps a UXView in a node
class UXNodeWrapperView: UXNodeView<SKNode>, UXView {
    static func wrapIfNotNode(_ child: UXView) -> UXView & GenNodeView {
        if let child = child as? UXView & GenNodeView {
            return child
        } else {
            return UXNodeWrapperView(child)
        }
    }

    let child: UXView

    var size: CGSize { child.size }

    init(_ child: UXView) {
        self.child = child
        super.init(node: SKNode())
        child.placeIn(parent: node)
    }
}
