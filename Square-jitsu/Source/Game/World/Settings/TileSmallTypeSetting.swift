//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileSmallTypeSetting: SerialSetting {
    var smallType: TileSmallType = TileSmallType(0)

    init() {}

    func decodeWellFormed(from json: JSON) throws {
        let typeAsUInt8 = try json.toUInt8()
        self.smallType = TileSmallType(typeAsUInt8)
    }

    func encodeWellFormed() throws -> JSON {
        JSON(String(smallType.rawValue))
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { smallType as! T }
}

extension TileSmallType: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TileSmallTypeSetting).smallType = self
    }
}