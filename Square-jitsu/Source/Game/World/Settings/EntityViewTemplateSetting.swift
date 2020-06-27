//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class EntityViewTemplateSetting: UnionSetting {
    static var options: [USOGenerator] = [
        USOGenerator(SettingOptionRecognizerByName("static"), StaticEntityViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("turret"), TurretEntityViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("laser"), LaserEntityViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("animated-by-lifetime"), AnimatedByLifetimeEntityViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("fade-on-death"), FadeOnDeathEntityViewTemplate.newSetting),
        USOGenerator(SettingOptionRecognizerByName("animated-on-death"), AnimatedOnDeathEntityViewTemplate.newSetting)
    ]

    init() { super.init(options: EntityViewTemplateSetting.options.map { $0.newOption() }) }
}