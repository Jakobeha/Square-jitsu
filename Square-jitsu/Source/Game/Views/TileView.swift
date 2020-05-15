//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileView: OptionalNodeView {
    private let world: World
    private let tileType: TileType

    private var settings: WorldSettings { world.settings }

    init(world: World, pos: WorldTilePos, tileType: TileType) {
        self.world = world
        self.tileType = tileType
        let template = world.settings.tileViewTemplates[tileType]
        super.init(node: template?.generateNode(world: world, pos: pos, tileType: tileType))
        if let node = node {
            // Uses chunk position because this node is a child of the chunk's node
            let chunkPos = pos.chunkTilePos
            node.position = chunkPos.cgPoint * settings.tileViewWidthHeight
            node.zPosition = tileType.bigType.layer.zPosition
        }
    }

    override func removeFromParent() {
        if let fadeDuration = settings.tileViewFadeDurations[tileType] {
            node?.zPosition += TileType.fadingZPositionOffset
            node?.run(SKAction.fadeOut(withDuration: fadeDuration)) {
                super.removeFromParent()
            }
        } else {
            super.removeFromParent()
        }
    }
}
