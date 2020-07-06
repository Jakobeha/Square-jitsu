//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class FadeOnDeathEntityViewTemplate: AugmentingEntityViewTemplate, SingleSettingCodable {
    let duration: CGFloat

    override var fadeAction: SKAction? {
        if let baseFadeAction = super.fadeAction {
            return SKAction.group([myFadeAction, baseFadeAction])
        } else {
            return myFadeAction
        }
    }

    private var myFadeAction: SKAction {
        SKAction.fadeOut(withDuration: TimeInterval(duration))
    }

    init(duration: CGFloat, base: EntityViewTemplate) {
        self.duration = duration
        super.init(base: base)
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
