//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class AnimatedOnDeathEntityViewTemplate: AugmentingEntityViewTemplate, SingleSettingCodable {
    let dyingTextureBase: TextureSet
    let duration: CGFloat

    // sourcery: nonSetting
    private let numDyingTextures: Int

    override var fadeAction: SKAction? {
        if let baseFadeAction = super.fadeAction {
            return SKAction.group([myFadeAction, baseFadeAction])
        } else {
            return myFadeAction
        }
    }

    private var myFadeAction: SKAction {
        SKAction.customAction(withDuration: TimeInterval(duration)) { node, currentTime in
            (node as! SKSpriteNode).texture = self.getDyingTextureAt(time: currentTime)
        }
    }

    init(dyingTextureBase: TextureSet, duration: CGFloat, base: EntityViewTemplate) {
        self.dyingTextureBase = dyingTextureBase
        self.duration = duration
        numDyingTextures = dyingTextureBase.count
        super.init(base: base)
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
