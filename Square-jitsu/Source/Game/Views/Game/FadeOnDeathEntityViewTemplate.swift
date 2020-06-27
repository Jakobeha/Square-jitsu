//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct FadeOnDeathEntityViewTemplate: EntityViewTemplate, SingleSettingCodable {
    let base: EntityViewTemplate
    let duration: CGFloat

    var fadeAction: SKAction? {
        SKAction.fadeOut(withDuration: TimeInterval(duration))
    }

    init(base: EntityViewTemplate, duration: CGFloat) {
        self.base = base
        self.duration = duration
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

    // region encoding and decoding
    typealias AsSetting = StructSetting<FadeOnDeathEntityViewTemplate>

    static func newSetting() -> StructSetting<FadeOnDeathEntityViewTemplate> {
        StructSetting(requiredFields: [
            "base": DeferredSetting { EntityViewTemplateSetting() },
            "duration": CGFloatRangeSetting(0...8)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
