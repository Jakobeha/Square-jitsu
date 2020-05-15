//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class UnclampedAngleSetting: SerialSetting {
    var value: UnclampedAngle = Angle.zero.toUnclamped

    func decodeWellFormed(from json: JSON) throws {
        let angleString = try json.toString()
        if let angle = UnclampedAngle(angleString) {
            value = angle
        } else {
            throw DecodeSettingError.badFormat(expectedDescription: "angle")
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(value.description)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { value as! T }
}

extension UnclampedAngle: SettingCodable {
    typealias AsSetting = UnclampedAngleSetting

    static func decode(from setting: UnclampedAngleSetting) -> UnclampedAngle {
        setting.value
    }

    func encode(to setting: UnclampedAngleSetting) {
        setting.value = self
    }
}
