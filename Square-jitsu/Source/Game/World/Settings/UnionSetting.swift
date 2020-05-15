//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Base class for a setting for a union.
/// You can support open unions (protocols) by subclassing, adding a static var of options,
/// and initializing with the static var
class UnionSetting: SerialSetting {
    private var options: [UnionSettingOption]

    private var selectedOptionIndex: Int

    private var selectedOption: UnionSettingOption { options[selectedOptionIndex] }
    private var selectedSetting: SerialSetting { selectedOption.setting }

    init(options: [UnionSettingOption]) {
        assert(!options.isEmpty, "need at least one option")
        self.options = options
        selectedOptionIndex = 0
    }

    func decodeWellFormed(from json: JSON) throws {
        for option in options {
            let chooseThisOption = option.recognizer.chooseThisOptionToDecode(json: json)
            if chooseThisOption {
                try option.setting.decode(from: json)
                return
            }
        }

        throw DecodeSettingError.noOptionsMatch
    }

    func encodeWellFormed() throws -> JSON {
        try selectedSetting.encodeWellFormed()
    }

    func validate() throws {
        for option in options {
            try option.setting.validate()
        }
    }

    func decodeDynamically<T>() -> T { selectedSetting.decodeDynamically() }
}