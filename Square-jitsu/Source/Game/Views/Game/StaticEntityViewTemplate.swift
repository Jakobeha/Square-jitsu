//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticEntityViewTemplate: EntityViewTemplate, SingleSettingCodable {
    typealias AsSetting = StructSetting<StaticEntityViewTemplate>

    let texture: SKTexture

    func generateNode(entity: Entity) -> SKNode {
        SKSpriteNode(texture: texture)
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
}
