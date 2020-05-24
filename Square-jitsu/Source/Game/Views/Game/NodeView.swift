//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class NodeView<Node: SKNode>: View, GenNodeView {
    let node: Node

    final var node_gen: SKNode { node }

    init(node: Node) {
        self.node = node
        super.init()
    }

    final override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        parent.addChild(node)
    }

    final override func removeFromParent() {
        super.removeFromParent()
        node.removeFromParent()
    }
}
