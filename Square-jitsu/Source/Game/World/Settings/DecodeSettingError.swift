//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum DecodeSettingError: Error, CustomStringConvertible {
    case wrongType(expected: Any.Type, actual: Type)
    case wrongTypeOfMany(anyExpected: [Any.Type], actual: Type)
    case cantDecodeNever
    case cantEncodeNever
    case wrongLength(expected: Int, actual: Int)
    case wrongKeys(required: Set<String>, optional: Set<String>, actual: Set<String>)
    case outOfRange(minDesc: String, maxDesc: String)
    case missingFields(Set<String>)
    case extraFields(Set<String>)
    case missingTypeField
    case badElement(index: Int, error: Error)
    case badDictionaryValue(keyDescription: String, error: Error)
    case badField(fieldName: String, error: Error)
    case badComplexEnumField(caseName: String, fieldName: String, error: Error)
    case badTypeMapEntry(bigTypeKey: TileBigType, smallTypeKey: TileSmallType, error: Error)
    case noOptionsMatch
    case invalidOption(myOption: String, validOptions: [String])
    case notAnAngleInDegrees
    case badFormat(expectedDescription: String)
    case missingComponentDependencies(target: String, dependenciesCNF: [[String]])
    case hasComponentConflicts(target: String, conflicts: [String])
    case noMetadataAtPos(pos3D: ChunkTilePos3D)

    /// Throws a `DecodeSettingError` if the length isn't expected
    static func assertLengthOf(array: [Any], expected: Int) throws {
        if array.count != expected {
            throw DecodeSettingError.wrongLength(expected: expected, actual: array.count)
        }
    }

    /// Throws a `DecodeSettingError` if the keys are wrong
    static func assertKeysIn(dictionary: [String:Any], requiredKeys: Set<String>, optionalKeys: Set<String> = []) throws {
        let actualKeys = Set(dictionary.keys)
        let actualKeysWithoutOptional = actualKeys.subtracting(optionalKeys)

        if actualKeysWithoutOptional != requiredKeys {
            throw DecodeSettingError.wrongKeys(required: requiredKeys, optional: optionalKeys, actual: actualKeys)
        }
    }

    var description: String {
        switch self {
        case .wrongType(let expected, let actual):
            return "Wrong type: expected \(expected) got \(actual)"
        case .wrongTypeOfMany(let anyExpected, let actual):
            let expectedDescription = anyExpected.map { type in String(describing: type) }.joined(separator: " or ")
            return "Wrong type: expected \(expectedDescription) got \(actual)"
        case .wrongKeys(let required, let optional, let actual):
            if optional.isEmpty {
                return "Wrong keys: expected \(required.joined(separator: ", ")) got \(actual.joined(separator: ", "))"
            } else {
                return "Wrong keys: expected \(required.joined(separator: ", ")) (and optionally \(optional.joined(separator: ", ")) got \(actual.joined(separator: ", "))"
            }
        case .cantDecodeNever:
            return "Didn't expect a value to exist here (to be decoded)"
        case .cantEncodeNever:
            return "Didn't expect a value to exist here (to be encoded)"
        case .wrongLength(let expected, let actual):
            return "Wrong length: expected \(expected) got \(actual)"
        case .outOfRange(let minDesc, let maxDesc):
            return "Must be in range: \(minDesc) to \(maxDesc) (inclusive)"
        case .missingFields(let missingFields):
            return "Missing fields in structure: \(missingFields)"
        case .extraFields(let extraFields):
            return "Extra fields in structure: \(extraFields)"
        case .missingTypeField:
            return "Missing type field to distinguish complex enum"
        case .badElement(let index, let error):
            return "At index \(index) - \(error)"
        case .badDictionaryValue(let keyDescription, let error):
            return "For key \(keyDescription) - \(error)"
        case .badField(let fieldName, let error):
            return "In \(fieldName) - \(error)"
        case .badComplexEnumField(let caseName, let fieldName, let error):
            return "In case \(caseName) field \(fieldName) - \(error)"
        case .badTypeMapEntry(let bigTypeKey, let smallTypeKey, let error):
            return "For type \(bigTypeKey)/\(smallTypeKey) - \(error)"
        case .invalidOption(let myOption, let validOptions):
            let validOptionsBullets = validOptions.map {validOption in "- \(validOption)" }.joined(separator: "\n")
            return "Invalid option: \(myOption). Valid options are:\n\(validOptionsBullets)"
        case .noOptionsMatch:
            return "No options match, don't know what type of data this is"
        case .notAnAngleInDegrees:
            return "Not an angle (must be of the form ###°)"
        case .badFormat(let expectedDescription):
            return "String isn't a valid \(expectedDescription)"
        case .missingComponentDependencies(let target, let dependenciesCNF):
            return "Component \(target) missing dependencies (in CNF): \(dependenciesCNF)"
        case .hasComponentConflicts(let target, let conflicts):
            return "Component \(target) can't be in an entity with any of these components: \(conflicts)"
        case .noMetadataAtPos(let pos3D):
            return "No metadata at \(pos3D)"
        }
    }
}
