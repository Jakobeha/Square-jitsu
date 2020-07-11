//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileViewTemplateSetting: UnionSetting {
    static var options: [USOGenerator] = [
        USOGenerator(SettingOptionRecognizerByName("static"), StaticTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("diamond4"), Diamond4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("square8"), Square8TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("edge4"), Edge4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("cornerFacing"), CornerFacingTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("destructible"), DestructibleTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("turret"), TurretTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("fadeOnRemove"), FadeOnRemoveTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("macro"), MacroTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("macroImage"), MacroImageTileViewTemplate.newSetting)
    ]

    init() { super.init(options: TileViewTemplateSetting.options.map { $0.newOption() }) }
}