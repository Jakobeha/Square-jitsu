//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileView: OptionalNodeView {
    init(world: World, chunkPos: ChunkTilePos, tileType: TileType) {
        let template = world.settings.tileViewConfigs[tileType]
        super.init(node: template?.generateNode(world: world, chunkPos: chunkPos, tileType: tileType))
        if let node = node {
            node.position = chunkPos.cgPoint * world.settings.tileViewWidthHeight
            node.zPosition = tileType.bigType.layer.zPosition
        }
    }
}
