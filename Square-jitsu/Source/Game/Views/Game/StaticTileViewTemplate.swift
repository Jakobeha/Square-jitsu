//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct StaticTileViewTemplate: TileViewTemplate, SingleSettingCodable {
    let texture: SKTexture

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    func didPlaceInParent(node: SKNode) {}

    func didRemoveFromParent(node: SKNode) {}

    // ---

    typealias AsSetting = StructSetting<StaticTileViewTemplate>

    static func newSetting() -> StructSetting<StaticTileViewTemplate> {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
}
