//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileViewTemplateSetting: UnionSetting {
    static var options: [UnionSettingOption] = [
        UnionSettingOption(SettingOptionRecognizerByName("static"), StaticTileViewTemplate.newSetting()),
        UnionSettingOption(SettingOptionRecognizerByName("adjacent4"), Adjacent4TileViewTemplate.newSetting()),
        UnionSettingOption(SettingOptionRecognizerByName("adjacent8"), Adjacent8TileViewTemplate.newSetting())
    ]

    init() { super.init(options: TileViewTemplateSetting.options) }
}