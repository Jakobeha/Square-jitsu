//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class StaticTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let texture: SKTexture

    init(texture: SKTexture) {
        self.texture = texture
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    override func generatePreviewNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<StaticTileViewTemplate>

    static func newSetting() -> StructSetting<StaticTileViewTemplate> {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
