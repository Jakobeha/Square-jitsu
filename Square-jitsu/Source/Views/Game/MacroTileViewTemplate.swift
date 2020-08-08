//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let texture: SKTexture

    init(texture: SKTexture) {
        self.texture = texture
        super.init()
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        guard let sizeInTiles = world.settings.macroTileSizes[tileType]?.toCgSize else {
            Logger.warnSettingsAreInvalid("macro template assigned to type '\(tileType)' which doesn't have a defined macro tile size")
            return SKNode()
        }

        let node = SKSpriteNode(texture: texture, size: world.settings.tileViewSize * sizeInTiles)
        node.anchorPoint = (CGSize.square(sideLength: 0.5) / sizeInTiles).toPoint
        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<MacroTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "texture": TextureSetting(),
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
