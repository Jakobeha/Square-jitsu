//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class NodeView: View {
    let node: SKNode

    init(node: SKNode) {
        self.node = node
        super.init()
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        parent.addChild(node)
    }

    override func removeFromParent() {
        super.removeFromParent()
        node.removeFromParent()
    }
}
