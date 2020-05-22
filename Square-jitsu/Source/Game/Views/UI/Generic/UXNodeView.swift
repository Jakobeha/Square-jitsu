//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UXNodeView<Node: SKNode>: NodeView<Node> {
    var topLeft: CGPoint = CGPoint.zero {
        didSet {
            node.position.x = topLeft.x
            updateNodePositionY()
        }
    }

    override init(node: Node) {
        super.init(node: node)
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        updateNodePositionY()
    }

    private func updateNodePositionY() {
        if let scene = node.scene {
            node.position.y = scene.size.height - topLeft.y
        }
    }
}
