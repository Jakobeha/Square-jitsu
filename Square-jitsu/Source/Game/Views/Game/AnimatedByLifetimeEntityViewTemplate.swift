//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class AnimatedByLifetimeEntityViewTemplate: EmptyEntityViewTemplate, SingleSettingCodable {
    let textureBase: TextureSet

    // sourcery: nonSetting
    private let numTextures: Int

    private var previewTexture: SKTexture { textureBase[0] }

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
        numTextures = textureBase.count
    }

    override func generateNode(entity: Entity) -> SKNode {
        SKSpriteNode(texture: getTextureFor(entity: entity))
    }

    override func generatePreviewNode(size: CGSize) -> SKNode {
        let node = SKSpriteNode(texture: previewTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    override func tick(entity: Entity, node: SKNode) {
        (node as! SKSpriteNode).texture = getTextureFor(entity: entity)
    }

    private func getTextureFor(entity: Entity) -> SKTexture {
        assert(entity.next.dalC != nil, "animatedByLifetime entity view requires the entity to have a lifetime component (dalC)")

        let lifetimeFractionUnclamped = entity.next.dalC!.lifetime / entity.next.dalC!.maxLifetime
        let lifetimeFraction = CGFloat.clamp(lifetimeFractionUnclamped, min: 0, max: 1)
        let textureIndexFraction = lifetimeFraction * CGFloat(numTextures)
        let textureIndex = Int(textureIndexFraction.rounded(.down))

        return textureBase[textureIndex]
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<AnimatedByLifetimeEntityViewTemplate>

    static func newSetting() -> StructSetting<AnimatedByLifetimeEntityViewTemplate> {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
