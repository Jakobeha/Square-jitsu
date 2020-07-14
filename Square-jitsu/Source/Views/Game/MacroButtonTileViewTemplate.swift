//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroButtonTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let foregroundTexture: SKTexture
    let sizeInTiles: CGSize

    init(foregroundTexture: SKTexture, sizeInTiles: CGSize) {
        self.foregroundTexture = foregroundTexture
        self.sizeInTiles = sizeInTiles
        super.init()
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        guard let tileBehavior = world.getBehaviorAt(pos3D: pos3D) as? ButtonBehavior else {
            Logger.warnSettingsAreInvalid("macro button template only allowed for button tiles")
            return SKNode()
        }

        // TODO: Show outline in editor so we know which tiles exist
        let adjoiningSides = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            world.peek(pos: adjacentPos).contains(tileType)
        })
        if adjoiningSides.isDisjoint(with: [.north, .west]) {
            var button = Button(texture: foregroundTexture) {
                tileBehavior.performAction(world: world, pos3D: pos3D)
            }
            // Need to offset button inside of the node since it uses UX coords
            button.topLeft = -CGSize.square(sideLength: world.settings.tileViewWidthHeight / 2).toPoint

            let node = SKNode()
            node.addChild(button.node)
            return node
        } else {
            return SKNode()
        }
    }

    override func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
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
            "sizeInTiles": CGSizeRangeSetting(width: 1...CGFloat(Chunk.widthHeight), height: 1...CGFloat(Chunk.widthHeight))
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
