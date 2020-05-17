//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class SimpleEnumSetting<Value: CaseIterable>: SerialSetting where Value.AllCases.Index == Int {
    private let options: [String] = Value.allCases.map { value in String(describing: value) }

    private var selectedOption: String =
            Value.allCases.first != nil ? String(describing: Value.allCases.first!) : ""

    private var selectedOptionIndex: Int { options.firstIndex(of: selectedOption) ?? -1 }
    var selectedValue: Value {
        get { Value.allCases[selectedOptionIndex] }
        set { selectedOption = String(describing: newValue) }
    }

    init() {}

    func decodeWellFormed(from json: JSON) throws {
        selectedOption = try json.toString()
    }

    func encodeWellFormed() throws -> JSON {
        JSON(selectedOption)
    }

    func validate() throws {
        if !options.contains(selectedOption) {
            throw DecodeSettingError.invalidOption(myOption: selectedOption, validOptions: options)
        }
    }

    func decodeDynamically<T>() -> T { selectedValue as! T }
}