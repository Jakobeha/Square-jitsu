//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroButtonTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let foregroundTexture: SKTexture

    init(foregroundTexture: SKTexture) {
        self.foregroundTexture = foregroundTexture
        super.init()
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        guard let tileBehavior = world.getBehaviorAt(pos3D: pos3D) as? ButtonBehavior else {
            Logger.warnSettingsAreInvalid("macro button template only allowed for button tiles")
            return SKNode()
        }

        var button = Button(owner: tileBehavior, texture: foregroundTexture) { (tileBehavior) in
            tileBehavior.performAction(world: world, pos3D: pos3D)
        }
        // Need to offset button inside of the node since it uses UX coords
        button.topLeft = -(world.settings.tileViewSize / 2).toPoint - CGPoint(x: 0, y: world.settings.tileViewWidthHeight)

        let node = SKNode()
        node.addChild(button.node)
        return node
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let backgroundNode = SKSpriteNode(texture: Button.background, size: size)
        backgroundNode.centerRect = Button.backgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0

        let foregroundNode = SKSpriteNode(texture: foregroundTexture, size: size)
        foregroundNode.anchorPoint = UXSpriteAnchor
        foregroundNode.zPosition = 1

        let node = SKNode()
        node.addChild(backgroundNode)
        node.addChild(foregroundNode)
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<MacroButtonTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "foregroundTexture": TextureSetting(),
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
