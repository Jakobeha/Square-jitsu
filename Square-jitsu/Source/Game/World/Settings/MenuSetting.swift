//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Allows the user to select a choice from a list of strings
class MenuSetting<Value>: SerialSetting {
    private let options: [String:Value]

    var selectedOption: String = ""

    var selectedValue: Value? { options[selectedOption] }

    init(options: [String:Value]) {
        self.options = options
    }

    func decodeWellFormed(from json: JSON) throws {
        selectedOption = try json.toString()
    }

    func encodeWellFormed() throws -> JSON {
        JSON(selectedOption)
    }

    func validate() throws {
        let validOptions = [String](options.keys)
        if !validOptions.contains(selectedOption) {
            throw DecodeSettingError.invalidOption(myOption: selectedOption, validOptions: validOptions)
        }
    }

    func decodeDynamically<T>() -> T { selectedValue! as! T }
}
