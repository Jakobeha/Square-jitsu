//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileTypeSetting: SerialSetting {
    var type: TileType = TileType.air

    init() {}

    func decodeWellFormed(from json: JSON) throws {
        let typeAsString = try json.toString()
        if let type = TileType(typeAsString) {
            self.type = type
        } else {
            throw DecodeSettingError.badFormat(expectedDescription: "type")
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(type.description)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { type as! T }
}

extension TileType: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TileTypeSetting).type = self
    }
}