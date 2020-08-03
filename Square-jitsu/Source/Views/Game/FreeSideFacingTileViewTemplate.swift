//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class FreeSideFacingTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let textureBase: TextureSet

    private var defaultTexture: SKTexture {
        textureBase[Side.east.textureName]
    }

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let side = tileType.orientation.asSide
        let texture = textureBase[side.textureName]

        let node = SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))

        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: defaultTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<FreeSideFacingTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
