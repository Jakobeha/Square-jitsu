//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

let UXSpriteAnchor: CGPoint = CGPoint(x: 0, y: 1)

protocol UXView {
    /// If either axis is infinity, that means we stretch as much as possible within the screen bounds
    var size: CGSize { get }

    var node: SKNode { get }

    mutating func set(sceneSize: CGSize)
}

extension UXView {
    var topLeft: CGPoint {
        get {
            var position = node.position
            // y position is inverted because this is UX coords
            position.y = -position.y
            return position
        }
        set {
            var position = newValue
            // y position is inverted because this is UX coords
            position.y = -position.y
            node.position = position
        }
    }
    var zPosition: CGFloat {
        get { node.zPosition }
        set { node.zPosition = newValue}
    }

    var bounds: CGRect { CGRect(origin: topLeft, size: size) }

    func set(parent: SKNode?) {
        if node.parent != nil {
            node.removeFromParent()
        }
        if let parent = parent {
            parent.addChild(node)
        }
    }
}