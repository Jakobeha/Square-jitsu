//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct AnimatedOnDeathEntityViewTemplate: EntityViewTemplate, SingleSettingCodable {
    let base: EntityViewTemplate
    let dyingTextureBase: TextureSet
    let duration: CGFloat

    // sourcery: nonSetting
    let numDyingTextures: Int

    var fadeAction: SKAction? {
        SKAction.customAction(withDuration: TimeInterval(duration)) { node, currentTime in
            (node as! SKSpriteNode).texture = self.getDyingTextureAt(time: currentTime)
        }
    }

    init(base: EntityViewTemplate, dyingTextureBase: TextureSet, duration: CGFloat) {
        self.base = base
        self.dyingTextureBase = dyingTextureBase
        self.duration = duration
        numDyingTextures = dyingTextureBase.count
    }

    func generateNode(entity: Entity) -> SKNode {
        base.generateNode(entity: entity)
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        base.generatePreviewNode(size: size)
    }

    func tick(entity: Entity, node: SKNode) {
        base.tick(entity: entity, node: node)
    }

    private func getDyingTextureAt(time: CGFloat) -> SKTexture {
        let fraction = time / duration
        let textureIndexFraction = fraction * CGFloat(numDyingTextures)
        let textureIndex = Int(textureIndexFraction.rounded(.down))

        return dyingTextureBase[textureIndex]
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<AnimatedOnDeathEntityViewTemplate>

    static func newSetting() -> StructSetting<AnimatedOnDeathEntityViewTemplate> {
        StructSetting(requiredFields: [
            "base": DeferredSetting { EntityViewTemplateSetting() },
            "dyingTextureBase": TextureSetSetting(),
            "duration": CGFloatRangeSetting(0...8)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
