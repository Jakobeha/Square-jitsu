//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileTypeMapSetting<Value>: SerialSetting {
    private let newValueSetting: () -> SerialSetting

    fileprivate var backing: [TileBigType:[SerialSetting?]] = [:]

    init(_ newValueSetting: @escaping () -> SerialSetting) {
        self.newValueSetting = newValueSetting
    }

    func haveValueSettingFor(bigType: TileBigType, smallType: TileSmallType) -> SerialSetting {
        if backing[bigType] == nil {
            backing[bigType] = []
        }

        let smallTypeIndex = Int(smallType.value)
        while backing[bigType]!.count < smallTypeIndex {
            backing[bigType]!.append(nil)
        }
        if backing[bigType]!.count == smallTypeIndex {
            backing[bigType]!.append(newValueSetting())
        } else if backing[bigType]![smallTypeIndex] == nil {
            backing[bigType]![smallTypeIndex] = newValueSetting()
        }

        return backing[bigType]![smallTypeIndex]!
    }

    func haveNoValueSettingFor(bigType: TileBigType, smallType: TileSmallType) {
        let smallTypeIndex = Int(smallType.value)
        backing[bigType]?[smallTypeIndex] = nil
    }

    func decodeWellFormed(from json: JSON) throws {
        let jsonDict = try json.toDictionary()
        for (bigTypeAsString, valuesAsJson) in jsonDict {
            guard let bigType = TileBigType(bigTypeAsString) else {
                throw DecodeSettingError.badFormat(expectedDescription: "type")
            }

            let valueAsJsons = try valuesAsJson.toArray()
            let valueSettings: [SerialSetting?] = try valueAsJsons.enumerated().map { (smallTypeIndex, valueAsJson) in
                if valueAsJson.isNull {
                    return nil
                } else {
                    let valueSetting = newValueSetting()

                    do {
                        try valueSetting.decodeWellFormed(from: valueAsJson)
                    } catch {
                        let smallType = TileSmallType(UInt8(smallTypeIndex))
                        throw DecodeSettingError.badTypeMapEntry(bigTypeKey: bigType, smallTypeKey: smallType, error: error)
                    }

                    return valueSetting
                }
            }

            backing[bigType] = valueSettings
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try backing.mapKeys { type in type.description }.mapValues { valueSettings in
            JSON(try valueSettings.map { valueSetting in
                if let valueSetting = valueSetting {
                    return try valueSetting.encodeWellFormed()
                } else {
                    return JSON.null
                }
            } as [JSON])
        } as [String:JSON])
    }

    func validate() throws {
        for valueSettings in backing.values {
            for valueSetting in valueSettings {
                if let valueSetting = valueSetting {
                    try valueSetting.validate()
                }
            }
        }
    }

    func decodeDynamically<T>() -> T {
        TileTypeMap<Value>(backing.mapValues { valueSettings in valueSettings.map { valueSetting in
            if let valueSetting = valueSetting {
                return valueSetting.decodeDynamically()
            } else {
                return nil
            }
        }}) as! T
    }
}

extension TileTypeMap: SettingCodable {
    typealias AsSetting = TileTypeMapSetting<Value>

    static func decode(from setting: TileTypeMapSetting<Value>) -> TileTypeMap {
        setting.decodeDynamically() as TileTypeMap<Value>
    }

    func encode(to setting: TileTypeMapSetting<Value>) {
        for (bigType, values) in backing {
            for (smallTypeIndex, value) in values.enumerated() {
                let smallType = TileSmallType(UInt8(smallTypeIndex))

                if let value = value {
                    let valueSetting = setting.haveValueSettingFor(bigType: bigType, smallType: smallType)
                    (value as! DynamicSettingCodable).encodeDynamically(to: valueSetting)
                } else {
                    setting.haveNoValueSettingFor(bigType: bigType, smallType: smallType)
                }
            }
        }
    }
}
