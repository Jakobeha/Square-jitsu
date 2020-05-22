//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol TileViewTemplate {
    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode
    func generatePreviewNode(size: CGSize) -> SKNode
}
