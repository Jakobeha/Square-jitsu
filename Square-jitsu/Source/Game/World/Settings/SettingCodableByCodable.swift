//
// Created by Jakob Hain on 5/15/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SettingCodableByCodable: Codable, DynamicSettingCodable {

}

extension SettingCodableByCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! CodableStructSetting<Self>).value = self
    }
}