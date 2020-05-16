//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class EntityViewTemplateSetting: UnionSetting {
    static var options: [USOGenerator] = [
        USOGenerator(SettingOptionRecognizerByName("static"), StaticEntityViewTemplate.newSetting)
    ]

    init() { super.init(options: EntityViewTemplateSetting.options.map { $0.newOption() }) }
}