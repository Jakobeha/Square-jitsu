//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class StaticEntityViewTemplate: EmptyEntityViewTemplate, SingleSettingCodable {
    let texture: SKTexture

    init(texture: SKTexture) {
        self.texture = texture
    }

    override func generateNode(entity: Entity) -> SKNode {
        SKSpriteNode(texture: texture)
    }

    override func generatePreviewNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<StaticEntityViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
