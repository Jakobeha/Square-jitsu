//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: View {
    private var tiles: [[[TileView]]] = [[[TileView]]]()

    init(world: World, chunkPos: ChunkTilePos, tile: Tile) {
        let prefab = world.settings.tileViewConfigs[tile.type]
        node = prefab?.generateNode()
        if let node = node {
            node.position = chunkPos.cgPoint * world.settings.tileViewWidthHeight
            addChild(node)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }
}
