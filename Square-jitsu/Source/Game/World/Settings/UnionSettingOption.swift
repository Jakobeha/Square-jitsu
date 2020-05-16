//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct UnionSettingOption {
    let recognizer: SettingOptionRecognizer
    let setting: SerialSetting

    init(recognizer: SettingOptionRecognizer, setting: SerialSetting) {
        self.recognizer = recognizer
        self.setting = setting
    }
}
