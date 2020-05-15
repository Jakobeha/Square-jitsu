//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SingleSettingCodable: SettingCodable {
    static func newSetting() -> AsSetting
}
