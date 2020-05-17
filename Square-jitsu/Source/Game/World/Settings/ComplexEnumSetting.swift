//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

private let ComplexEnumSettingSelectedCaseKey: String = "type"

class ComplexEnumSetting<Value: SettingCodable>: SerialSetting {
    private let cases: [String:[String:SerialSetting]]
    private let emptyCases: Set<String>
    private let customValidator: ((ComplexEnumSetting<Value>) throws -> ())?

    var selectedCase: String
    var selectedCaseFieldSettings: [String:SerialSetting] { cases[selectedCase]! }

    /// customValidator is a lambda partially because StructSetting is used by Sourcery generated code, also because it's easy
    init(cases: [String:[String:SerialSetting]], customValidator: ((ComplexEnumSetting<Value>) throws -> ())? = nil) {
        assert(
            cases.values.allSatisfy { fieldSettings in !fieldSettings.keys.contains(ComplexEnumSettingSelectedCaseKey) },
            "enum case's field can't contain the field to distinguish the enum case: \(ComplexEnumSettingSelectedCaseKey)"
        )
        self.cases = cases
        emptyCases = Set(cases.filter { (_, value) in value.isEmpty }.keys)
        selectedCase = cases.keys.first ?? ""
        self.customValidator = customValidator
    }

    func decodeWellFormed(from json: JSON) throws {
        if let selectedCase = json.string {
            if emptyCases.contains(selectedCase) {
                self.selectedCase = selectedCase
            } else {
                throw DecodeSettingError.invalidOption(myOption: selectedCase, validOptions: [String](emptyCases))
            }
        } else if let jsonDict = json.dictionary {
            guard let caseJson = jsonDict[ComplexEnumSettingSelectedCaseKey] else {
                throw DecodeSettingError.missingTypeField
            }
            let selectedCase = try caseJson.toString()
            guard let caseSettings = cases[selectedCase] else {
                throw DecodeSettingError.invalidOption(myOption: selectedCase, validOptions: [String](cases.keys))
            }
            self.selectedCase = selectedCase

            // Decode case's field settings
            for (fieldName, fieldSetting) in caseSettings {
                let field = jsonDict[fieldName]!
                do {
                    try fieldSetting.decodeWellFormed(from: field)
                } catch {
                    throw DecodeSettingError.badComplexEnumField(caseName: selectedCase, fieldName: fieldName, error: error)
                }
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        var jsonDict: [String:JSON] = [ComplexEnumSettingSelectedCaseKey: JSON(selectedCase)]
        let caseSettings = cases[selectedCase]!
        for (fieldName, fieldSetting) in caseSettings {
            jsonDict[fieldName] = try fieldSetting.encodeWellFormed()
        }
        return JSON(jsonDict)
    }

    func validate() throws {
        for (caseName, caseSettings) in cases {
            for (fieldName, fieldSetting) in caseSettings {
                do {
                    try fieldSetting.validate()
                } catch {
                    throw DecodeSettingError.badComplexEnumField(caseName: caseName, fieldName: fieldName, error: error)
                }
            }
        }
    }

    func decodeDynamically<T>() -> T { Value.decode(from: self as! Value.AsSetting) as! T }
}
