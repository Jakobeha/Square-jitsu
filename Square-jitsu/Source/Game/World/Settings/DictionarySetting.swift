//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class DictionarySetting<Key: LosslessStringConvertibleEnum & CaseIterable & Hashable, Value>: SerialSetting {
    private static var allPossibleKeyStrings: [String] {
        Key.allCases.map { key in key.description }
    }

    private let newValueSetting: () -> SerialSetting

    private var settings: [Key:SerialSetting] = [:]

    init(newValueSetting: @escaping () -> SerialSetting) {
        self.newValueSetting = newValueSetting
    }

    func decodeWellFormed(from json: JSON) throws {
        let jsonDictionary = try json.toDictionary()
        let keyMappedDictionary: [Key:JSON] = try jsonDictionary.mapKeys { stringKey in
            if let key = Key(stringKey) {
                return key
            } else {
                throw DecodeSettingError.invalidOption(myOption: stringKey, validOptions: DictionarySetting<Key, Value>.allPossibleKeyStrings)
            }
        }
        setElementSettingKeysTo(keys: keyMappedDictionary.keys)
        for (key, valueJson) in keyMappedDictionary {
            let valueSetting = settings[key]!
            do {
                try valueSetting.decodeWellFormed(from: valueJson)
            } catch {
                throw DecodeSettingError.badDictionaryValue(keyDescription: key.description, error: error)
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try settings.mapToDict { (key, valueSetting) in
            do {
                return (key: key.description, value: try valueSetting.encodeWellFormed())
            } catch {
                throw DecodeSettingError.badDictionaryValue(keyDescription: key.description, error: error)
            }
        } as [String:JSON])
    }

    private func setElementSettingKeysTo<T>(keys: Dictionary<Key, T>.Keys) {
        let oldKeySet = Set(settings.keys)
        let newKeySet = Set(keys)
        for removedKey in oldKeySet.subtracting(newKeySet) {
            settings[removedKey] = nil
        }
        for addedKey in newKeySet.subtracting(oldKeySet) {
            settings[addedKey] = newValueSetting()
        }
    }

    func validate() throws {
        for (key, valueSetting) in settings {
            do {
                try valueSetting.validate()
            } catch {
                throw DecodeSettingError.badDictionaryValue(keyDescription: key.description, error: error)
            }
        }
    }

    func decodeDynamically<T>() -> T {
        settings.mapValues { valueSetting in
            valueSetting.decodeDynamically() as Value
        } as! T
    }

    func encodeDynamically(_ dictionary: [Key:Value]) {
        setElementSettingKeysTo(keys: dictionary.keys)
        for (key, value) in dictionary {
            let valueSetting = settings[key]!
            (value as! DynamicSettingCodable).encodeDynamically(to: valueSetting)
        }
    }
}

extension Dictionary where Key: LosslessStringConvertibleEnum & CaseIterable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! DictionarySetting<Key, Value>).encodeDynamically(self)
    }
}