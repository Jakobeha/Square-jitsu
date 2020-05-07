//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileView: View {
    private let node: SKNode?

    init(world: World, chunkPos: ChunkTilePos, tileType: TileType) {
        let template = world.settings.tileViewConfigs[tileType]
        node = template?.generateNode(settings: world.settings)
        if let node = node {
            node.position = chunkPos.cgPoint * world.settings.tileViewWidthHeight
        }
    }

    override func place(parent: SKNode) {
        super.place(parent: parent)
        if let node = node {
            parent.addChild(node)
        }
    }

    override func remove() {
        super.remove()
        node?.removeFromParent()
    }
}
