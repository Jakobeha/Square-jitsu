//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class IndicatedInEditorTileViewTemplate: AugmentingTileViewTemplate, SingleSettingCodable {
    let editorIndicator: TileViewTemplate & DynamicSettingCodable

    init(editorIndicator: TileViewTemplate, base: TileViewTemplate?) {
        self.editorIndicator = editorIndicator as! TileViewTemplate & DynamicSettingCodable
        super.init(base: base)
    }

    override func generateEditorIndicatorNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode? {
        editorIndicator.generateNode(world: world, pos3D: pos3D, tileType: tileType)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<IndicatedInEditorTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": OptionalSetting<TileViewTemplate>(DeferredSetting { TileViewTemplateSetting() }),
            "editorIndicator": DeferredSetting { TileViewTemplateSetting() }
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
