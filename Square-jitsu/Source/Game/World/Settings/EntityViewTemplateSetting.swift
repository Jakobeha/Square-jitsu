//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class EntityViewTemplateSetting: UnionSetting {
    static var options: [UnionSettingOption] = [
        UnionSettingOption(SettingOptionRecognizerByName("static"), StaticEntityViewTemplate.newSetting())
    ]

    init() { super.init(options: EntityViewTemplateSetting.options) }
}