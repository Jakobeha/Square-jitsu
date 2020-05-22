//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticTileViewTemplate: TileViewTemplate, SingleSettingCodable {
    typealias AsSetting = StructSetting<StaticTileViewTemplate>

    let texture: SKTexture

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        SKSpriteNode(texture: texture, size: size)
    }

    static func newSetting() -> StructSetting<StaticTileViewTemplate> {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
}
