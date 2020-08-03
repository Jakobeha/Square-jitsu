//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a 2D vector by selecting each number from a range
class RelativePosSetting: SerialSetting {
    var value: RelativePos = RelativePos(x: 0, y: 0)

    func decodeWellFormed(from json: JSON) throws {
        let vectorArray = try json.toArray()
        try DecodeSettingError.assertLengthOf(array: vectorArray, expected: 2)

        let x = try vectorArray[0].toInt()
        let y = try vectorArray[1].toInt()

        value = RelativePos(x: x, y: y)
    }

    func encodeWellFormed() throws -> JSON {
        JSON([JSON(value.x), JSON(value.y)])
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { value as! T }
}

extension RelativePos: SettingCodable {
    typealias AsSetting = RelativePosSetting

    static func decode(from setting: RelativePosSetting) -> RelativePos {
        setting.value
    }

    func encode(to setting: RelativePosSetting) {
        setting.value = self
    }
}
