//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SettingCodable: DynamicSettingCodable {
    associatedtype AsSetting: SerialSetting

    static func decode(from setting: AsSetting) -> Self
    func encode(to setting: AsSetting)
}

extension SettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        encode(to: setting as! AsSetting)
    }
}