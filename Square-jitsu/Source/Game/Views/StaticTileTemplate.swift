//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticTileTemplate: TileTemplate {
    private let texture: SKTexture

    init(textureName: String) {
        self.init(texture: SKTexture(imageNamed: textureName))
    }

    init(texture: SKTexture) {
        self.texture = texture
    }

    func generateNode(settings: Settings) -> SKNode {
        SKSpriteNode(texture: texture, size: CGSize.square(sideLength: settings.tileViewWidthHeight))
    }
}
