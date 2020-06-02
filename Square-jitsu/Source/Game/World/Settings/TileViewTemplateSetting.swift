//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileViewTemplateSetting: UnionSetting {
    static var options: [USOGenerator] = [
        USOGenerator(SettingOptionRecognizerByName("static"), StaticTileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("adjacent4"), Adjacent4TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("adjacent8"), Adjacent8TileViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("turret"), TurretTileViewTemplate.newSetting)
    ]

    init() { super.init(options: TileViewTemplateSetting.options.map { $0.newOption() }) }
}