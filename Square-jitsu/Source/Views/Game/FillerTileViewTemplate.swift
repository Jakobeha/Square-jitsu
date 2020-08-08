//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class FillerTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let texture: SKTexture

    init(texture: SKTexture) {
        self.texture = texture
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let side = tileType.orientation.asFillerOrientation.direction

        let numRightAngleRotations = side.rawValue
        let rotation = Angle(numRightAngleRotations: numRightAngleRotations)

        let node = SKSpriteNode(texture: texture, size: world.settings.tileViewSize)
        node.angle = rotation

        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<FillerTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "texture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
