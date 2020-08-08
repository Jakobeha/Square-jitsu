//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class FreeOptionalSideFacingTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    private static let noneTextureName: String = "None"

    let textureBase: TextureSet

    private var defaultTexture: SKTexture {
        textureBase[FreeOptionalSideFacingTileViewTemplate.noneTextureName]
    }

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let side = tileType.orientation.asOptionalSide
        let textureName = side?.textureName ?? FreeOptionalSideFacingTileViewTemplate.noneTextureName
        let texture = textureBase[textureName]

        let node = SKSpriteNode(texture: texture, size: world.settings.tileViewSize)

        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: defaultTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<FreeOptionalSideFacingTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
