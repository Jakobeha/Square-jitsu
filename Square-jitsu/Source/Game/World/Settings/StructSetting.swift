//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class StructSetting<Value: SettingCodable>: SerialSetting {
    private let requiredFieldSettings: [String:SerialSetting]
    private let optionalFieldSettings: [String:SerialSetting]
    let allFieldSettings: [String:SerialSetting]
    private let allowedExtraFields: Set<String>
    private let customValidator: ((StructSetting<Value>) throws -> ())?

    private var usedOptionalFields: Set<String> = []
    var usedFieldSettings: [String:SerialSetting]

    /// customValidator is a lambda partially because StructSetting is used by Sourcery generated code, also because it's easy
    init(requiredFields: [String:SerialSetting], optionalFields: [String:SerialSetting], allowedExtraFields: Set<String> = [], customValidator: ((StructSetting<Value>) throws -> ())? = nil) {
        assert(
            !allowedExtraFields.contains(anyOf: requiredFields.keys) &&
            !allowedExtraFields.contains(anyOf: optionalFields.keys) &&
            !Set(requiredFields.keys).contains(anyOf: optionalFields.keys)
        )
        self.requiredFieldSettings = requiredFields
        self.optionalFieldSettings = optionalFields
        self.allowedExtraFields = allowedExtraFields
        self.customValidator = customValidator
        allFieldSettings = requiredFieldSettings.merging(optionalFieldSettings) { _, _ in fatalError("not possible") }
        usedFieldSettings = requiredFields
    }

    func decodeWellFormed(from json: JSON) throws {
        usedOptionalFields = []
        usedFieldSettings = requiredFieldSettings

        let jsonDict = try json.toDictionary()

        // Throw on missing / extra fields
        let requiredFieldSet = Set(requiredFieldSettings.keys)
        let jsonDictSet = Set(jsonDict.keys)
        let missingFields = requiredFieldSet.subtracting(jsonDictSet)
        if !missingFields.isEmpty {
            throw DecodeSettingError.missingFields(missingFields)
        }
        let extraFields = Set(jsonDictSet).subtracting(requiredFieldSet).subtracting(optionalFieldSettings.keys).subtracting(allowedExtraFields)
        if !extraFields.isEmpty {
            throw DecodeSettingError.extraFields(extraFields)
        }

        // Decode field settings
        for (fieldName, fieldSetting) in requiredFieldSettings {
            let field = jsonDict[fieldName]!
            do {
                try fieldSetting.decodeWellFormed(from: field)
            } catch {
                throw DecodeSettingError.badField(fieldName: fieldName, error: error)
            }
        }
        for (fieldName, fieldSetting) in optionalFieldSettings {
            if let field = jsonDict[fieldName] {
                usedOptionalFields.appendOrInsert(fieldName)
                usedFieldSettings[fieldName] = fieldSetting
                do {
                    try fieldSetting.decodeWellFormed(from: field)
                } catch {
                    throw DecodeSettingError.badField(fieldName: fieldName, error: error)
                }
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try usedFieldSettings.mapValues { fieldSetting in
            try fieldSetting.encodeWellFormed()
        })
    }

    func validate() throws {
        for (fieldName, fieldSetting) in requiredFieldSettings {
            do {
                try fieldSetting.validate()
            } catch {
                throw DecodeSettingError.badField(fieldName: fieldName, error: error)
            }
        }
        for (fieldName, fieldSetting) in optionalFieldSettings {
            do {
                try fieldSetting.validate()
            } catch {
                throw DecodeSettingError.badField(fieldName: fieldName, error: error)
            }
        }
        try customValidator?(self)
    }

    func decodeDynamically<T>() -> T { Value.decode(from: self as! Value.AsSetting) as! T }
}
