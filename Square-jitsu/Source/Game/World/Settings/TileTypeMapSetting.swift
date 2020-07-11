//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileTypeMapSetting<Value>: SerialSetting {
    private let newValueSetting: (TileType) -> SerialSetting

    fileprivate var backing: [TileBigType:[SerialSetting?]] = [:]

    convenience init(_ newValueSetting: @escaping () -> SerialSetting) {
        self.init({ _ in newValueSetting() })
    }

    init(_ newValueSetting: @escaping (TileType) -> SerialSetting) {
        self.newValueSetting = newValueSetting
    }

    func haveValueSettingFor(bigType: TileBigType, smallType: TileSmallType) -> SerialSetting {
        let type = TileType(bigType: bigType, smallType: smallType)

        if backing[bigType] == nil {
            backing[bigType] = []
        }

        let smallTypeIndex = Int(smallType.rawValue)
        while backing[bigType]!.count < smallTypeIndex {
            backing[bigType]!.append(nil)
        }
        if backing[bigType]!.count == smallTypeIndex {
            backing[bigType]!.append(newValueSetting(type))
        } else if backing[bigType]![smallTypeIndex] == nil {
            backing[bigType]![smallTypeIndex] = newValueSetting(type)
        }

        return backing[bigType]![smallTypeIndex]!
    }

    func haveNoValueSettingFor(bigType: TileBigType, smallType: TileSmallType) {
        let smallTypeIndex = Int(smallType.rawValue)
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
                    let smallType = TileSmallType(UInt8(smallTypeIndex))
                    let type = TileType(bigType: bigType, smallType: smallType)

                    let valueSetting = newValueSetting(type)

                    do {
                        try valueSetting.decodeWellFormed(from: valueAsJson)
                    } catch {
                        throw DecodeSettingError.badTypeMapEntry(bigTypeKey: bigType, smallTypeKey: smallType, error: error)
                    }

                    return valueSetting
                }
            }

            backing[bigType] = valueSettings
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try backing.mapToDict { (bigType, valueSettings) in
            let valueJsons = JSON(try valueSettings.enumerated().map { (smallTypeIndex, valueSetting) in
                if let valueSetting = valueSetting {
                    do {
                        return try valueSetting.encodeWellFormed()
                    } catch {
                        let smallType = TileSmallType(UInt8(smallTypeIndex))
                        throw DecodeSettingError.badTypeMapEntry(bigTypeKey: bigType, smallTypeKey: smallType, error: error)
                    }
                } else {
                    return JSON.null
                }
            } as [JSON])
            return (key: bigType.description, value: valueJsons)
        } as [String:JSON])
    }

    func validate() throws {
        for (bigType, valueSettings) in backing {
            for (smallTypeIndex, valueSetting) in valueSettings.enumerated() {
                if let valueSetting = valueSetting {
                    do {
                        try valueSetting.validate()
                    } catch {
                        let smallType = TileSmallType(UInt8(smallTypeIndex))
                        throw DecodeSettingError.badTypeMapEntry(bigTypeKey: bigType, smallTypeKey: smallType, error: error)
                    }
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
