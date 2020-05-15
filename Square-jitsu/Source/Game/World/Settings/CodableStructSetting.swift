//
// Created by Jakob Hain on 5/15/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

private let CodableStructSettingDecoder: JSONDecoder = JSONDecoder()
private let CodableStructSettingEncoder: JSONEncoder = JSONEncoder()

class CodableStructSetting<Value: Codable>: SerialSetting {
    var value: Value? = nil

    func decodeWellFormed(from json: JSON) throws {
        let jsonData = try json.rawData()
        value = try CodableStructSettingDecoder.decode(Value.self, from: jsonData)
    }

    func encodeWellFormed() throws -> JSON {
        let jsonData = try CodableStructSettingEncoder.encode(value)
        return try JSON(data: jsonData)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { value as! T }
}