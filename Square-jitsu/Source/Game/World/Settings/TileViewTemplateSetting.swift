//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileViewTemplateSetting: UnionSetting {
    static var options: [USOGenerator] = [
        USOGenerator(SettingOptionRecognizerByName("color"), ColorTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("static"), StaticTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("continuouslyAnimated"), ContinuouslyAnimatedTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("diamond4"), Diamond4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("square8"), Square8TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("edge4"), Edge4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("free4"), Free4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("sideFacing"), SideFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("optionalSideFacing"), OptionalSideFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("filler"), FillerTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("cornerFacing"), CornerFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("freeSideFacing"), FreeSideFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("freeCornerFacing"), FreeCornerFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("freeOptionalSideFacing"), FreeOptionalSideFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("destructible"), DestructibleTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("turret"), TurretTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("fadeOnRemove"), FadeOnRemoveTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("glossy"), GlossyTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("macro"), MacroTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("macroImage"), MacroImageTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("macroButton"), MacroButtonTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("withAlternatePreview"), WithAlternatePreviewTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("indicatedInEditor"), IndicatedInEditorTileViewTemplate.newSetting)
    ]

    init() { super.init(options: TileViewTemplateSetting.options.map { $0.newOption() }) }
}