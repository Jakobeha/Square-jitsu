//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class GlossyTileViewTemplate: AugmentingTileViewTemplate, SingleSettingCodable {
    /// If this is provided, the gloss node will be this template's regular (not gloss) node.
    /// Otherwise, the gloss node will be the base's regular node
    let explicitGlossTemplate: (TileViewTemplate & DynamicSettingCodable)?

    private var usesGlossTemplate: Bool {
        explicitGlossTemplate != nil
    }

    init(explicitGlossTemplate: TileViewTemplate?, base: TileViewTemplate?) {
        self.explicitGlossTemplate = explicitGlossTemplate as! (TileViewTemplate & DynamicSettingCodable)?
        super.init(base: base)
    }

    override func generateGlossNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode? {
        usesGlossTemplate ?
            explicitGlossTemplate!.generateNode(world: world, pos3D: pos3D, tileType: tileType) :
            base?.generateNode(world: world, pos3D: pos3D, tileType: tileType)
    }

    override func generateGlossPreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode? {
        usesGlossTemplate ?
            explicitGlossTemplate!.generatePreviewNodeRaw(size: size, settings: settings) :
            base?.generatePreviewNodeRaw(size: size, settings: settings)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<GlossyTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": OptionalSetting<TileViewTemplate>(DeferredSetting { TileViewTemplateSetting() }),
            "explicitGlossTemplate": OptionalSetting<TileViewTemplate>(DeferredSetting { TileViewTemplateSetting() })
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
