//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// UnionSettingOptionGenerator; abbreviated because it's used often as a key-value tuple, and as boilerplate
struct USOGenerator {
    private let recognizer: SettingOptionRecognizer
    private let newSetting: () -> SerialSetting

    init(_ recognizer: SettingOptionRecognizer, _ newSetting: @escaping () -> SerialSetting) {
        self.recognizer = recognizer
        self.newSetting = newSetting
    }

    func newOption() -> UnionSettingOption {
        UnionSettingOption(recognizer: recognizer, setting: newSetting())
    }
}
