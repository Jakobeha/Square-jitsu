//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class WithAlternatePreviewTileViewTemplate: AugmentingTileViewTemplate, SingleSettingCodable {
    let preview: TileViewTemplate & DynamicSettingCodable

    init(preview: TileViewTemplate, base: TileViewTemplate?) {
        self.preview = preview as! TileViewTemplate & DynamicSettingCodable
        super.init(base: base)
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        preview.generatePreviewNodeRaw(size: size, settings: settings)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<WithAlternatePreviewTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": OptionalSetting<TileViewTemplate>(DeferredSetting { TileViewTemplateSetting() }),
            "preview": DeferredSetting { TileViewTemplateSetting() }
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
