//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class CornerFacingTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let textureBase: TextureSet

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let corner = tileType.orientation.asCorner

        let textureName = corner.isActualCorner ? "NorthEast" : "East"
        let texture = textureBase[textureName]

        // 0 for east, rounds down to 0 for north east, 1 for north, rounds down to 1 for north west ...
        let numRightAngleRotations = corner.rawValue / 2
        let rotation = Angle(numRightAngleRotations: numRightAngleRotations)

        let node = SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
        node.angle = rotation

        return node
    }

    override func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: textureBase["East"], size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<CornerFacingTileViewTemplate>

    static func newSetting() -> StructSetting<CornerFacingTileViewTemplate> {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
