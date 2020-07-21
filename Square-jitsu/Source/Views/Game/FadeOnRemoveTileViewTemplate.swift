//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class FadeOnRemoveTileViewTemplate: AugmentingTileViewTemplate, SingleSettingCodable {
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

    init(duration: CGFloat, base: TileViewTemplate?) {
        self.duration = duration
        super.init(base: base)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<FadeOnRemoveTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": DeferredSetting { TileViewTemplateSetting() },
            "duration": CGFloatRangeSetting(0...16)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
