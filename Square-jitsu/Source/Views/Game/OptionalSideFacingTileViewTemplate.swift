//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class OptionalSideFacingTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let sideTexture: SKTexture
    let noneTexture: SKTexture

    init(sideTexture: SKTexture, noneTexture: SKTexture) {
        self.sideTexture = sideTexture
        self.noneTexture = noneTexture
        super.init()
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let nodeSize = world.settings.tileViewSize

        if let side = tileType.orientation.asOptionalSide {
            let numRightAngleRotations = side.rawValue
            let rotation = Angle(numRightAngleRotations: numRightAngleRotations)

            let node = SKSpriteNode(texture: sideTexture, size: nodeSize)
            node.angle = rotation

            return node
        } else {
            let node = SKSpriteNode(texture: noneTexture, size: nodeSize)
            return node
        }
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: noneTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<OptionalSideFacingTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "sideTexture": TextureSetting(),
            "noneTexture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
