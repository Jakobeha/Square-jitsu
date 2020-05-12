//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticTileViewTemplate: TileViewTemplate {
    private let texture: SKTexture

    init(textureName: String) {
        self.init(texture: SKTexture(imageNamed: textureName))
    }

    init(texture: SKTexture) {
        self.texture = texture
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }
}
