//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class StructSetting<Value: SettingCodable>: SerialSetting {
    let fieldSettings: [String:SerialSetting]
    private let allowedExtraFields: Set<String>
    private let customValidator: ((StructSetting<Value>) throws -> ())?

    /// customValidator is a lambda partially because StructSetting is used by Sourcery generated code, also because it's easy
    init(_ fields: [String:SerialSetting], allowedExtraFields: Set<String> = [], customValidator: ((StructSetting<Value>) throws -> ())? = nil) {
        assert(!allowedExtraFields.contains(anyOf: fields.keys))
        self.fieldSettings = fields
        self.allowedExtraFields = allowedExtraFields
        self.customValidator = customValidator
    }

    func decodeWellFormed(from json: JSON) throws {
        let jsonDict = try json.toDictionary()

        // Throw on missing / extra fields
        let fieldSet = Set(fieldSettings.keys)
        let jsonDictSet = Set(jsonDict.keys)
        let missingFields = fieldSet.subtracting(jsonDictSet)
        if !missingFields.isEmpty {
            throw DecodeSettingError.missingFields(missingFields)
        }
        let extraFields = Set(jsonDictSet).subtracting(fieldSet).subtracting(allowedExtraFields)
        if !extraFields.isEmpty {
            throw DecodeSettingError.extraFields(extraFields)
        }

        // Decode field settings
        for (fieldName, field) in jsonDict {
            if !allowedExtraFields.contains(fieldName) {
                let fieldSetting = fieldSettings[fieldName]!
                do {
                    try fieldSetting.decodeWellFormed(from: field)
                } catch {
                    throw DecodeSettingError.badField(fieldName: fieldName, error: error)
                }
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try fieldSettings.mapValues { fieldSetting in
            try fieldSetting.encodeWellFormed()
        })
    }

    func validate() throws {
        for fieldSetting in fieldSettings.values {
            try fieldSetting.validate()
        }
        try customValidator?(self)
    }

    func decodeDynamically<T>() -> T { Value.decode(from: self as! Value.AsSetting) as! T }
}
