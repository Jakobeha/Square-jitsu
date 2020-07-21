//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class ColorTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let color: SKColor

    init(color: SKColor) {
        self.color = color
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        SKSpriteNode(texture: nil, color: color, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: nil, color: color, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<ColorTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "color": ColorSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
