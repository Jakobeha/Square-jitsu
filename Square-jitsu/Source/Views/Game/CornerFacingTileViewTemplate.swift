//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class CornerFacingTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    private static let cornerTextureName: String = "NorthEast"
    private static let sideTextureName: String = "East"
    
    let textureBase: TextureSet

    private var defaultTexture: SKTexture {
        textureBase[CornerFacingTileViewTemplate.sideTextureName]
    }

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let corner = tileType.orientation.asCorner

        let textureName = corner.isActualCorner ?
                CornerFacingTileViewTemplate.cornerTextureName :
                CornerFacingTileViewTemplate.sideTextureName
        let texture = textureBase[textureName]

        // 0 for east, rounds down to 0 for north east, 1 for north, rounds down to 1 for north west ...
        let numRightAngleRotations = corner.rawValue / 2
        let rotation = Angle(numRightAngleRotations: numRightAngleRotations)

        let node = SKSpriteNode(texture: texture, size: world.settings.tileViewSize)
        node.angle = rotation

        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: defaultTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<CornerFacingTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
