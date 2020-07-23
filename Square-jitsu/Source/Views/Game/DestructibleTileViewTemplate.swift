//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class DestructibleTileViewTemplate: AugmentingTileViewTemplate, SingleSettingCodable {
    private static let destructionNodeName: String = "destructionNode"

    let destructionTexture: SKTexture

    init(destructionTexture: SKTexture, base: TileViewTemplate?) {
        self.destructionTexture = destructionTexture
        super.init(base: base)
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let baseNode = super.generateNode(world: world, pos3D: pos3D, tileType: tileType)
        let destructionNode = SKSpriteNode(texture: destructionTexture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
        baseNode.addChild(destructionNode)

        let maxHealth = world.settings.destructibleSolidInitialHealth[tileType] ?? 0

        if let destructibleBehavior = world.getBehaviorAt(pos3D: pos3D) as? DestructibleBehavior {
            func updateDestructionAmount(destructionNode: SKNode) {
                let healthFraction = destructibleBehavior.health / maxHealth
                destructionNode.alpha = 1 - healthFraction
            }

            updateDestructionAmount(destructionNode: destructionNode)
            destructibleBehavior.didChangeHealth.subscribe(observer: destructionNode, priority: .view, handler: updateDestructionAmount)
        } else {
            Logger.warnSettingsAreInvalid("destructible view on non-destructible tile")
        }

        return baseNode
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<DestructibleTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": DeferredSetting { TileViewTemplateSetting() },
            "destructionTexture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
