//
// Created by Jakob Hain on 5/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol SimpleEnumSettingCodable: DynamicSettingCodable, CaseIterable where AllCases.Index == Int {}

extension SimpleEnumSettingCodable {
    static func newSetting() -> SimpleEnumSetting<Self> { SimpleEnumSetting<Self>() }

    func encodeDynamically(to setting: SerialSetting) {
        (setting as! SimpleEnumSetting<Self>).selectedValue = self
    }
}