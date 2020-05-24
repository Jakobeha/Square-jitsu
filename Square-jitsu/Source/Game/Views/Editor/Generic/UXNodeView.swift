//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UXNodeView<Node: SKNode>: NodeView<Node> {
    var topLeft: CGPoint = CGPoint.zero {
        didSet {
            // Invert y because in UI coords, y goes from top to bottom
            // whereas in SpriteKit coords, y goes from bottom to top
            node.position = CGPoint(x: topLeft.x, y: -topLeft.y)
        }
    }

    override init(node: Node) {
        super.init(node: node)
    }
}
