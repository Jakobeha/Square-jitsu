//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticEntityViewTemplate: EntityViewTemplate {
    private let texture: SKTexture

    init(textureName: String) {
        self.init(texture: SKTexture(imageNamed: textureName))
    }

    init(texture: SKTexture) {
        self.texture = texture
    }

    func generateNode(entity: Entity) -> SKNode {
        SKSpriteNode(texture: texture)
    }
}
