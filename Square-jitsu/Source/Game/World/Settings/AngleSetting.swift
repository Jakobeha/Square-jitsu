//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class AngleSetting: SerialSetting {
    var value: Angle = Angle.zero

    func decodeWellFormed(from json: JSON) throws {
        let angleString = try json.toString()
        if let angle = Angle(angleString) {
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

extension Angle: SettingCodable {
    typealias AsSetting = AngleSetting

    static func decode(from setting: AngleSetting) -> Angle {
        setting.value
    }

    func encode(to setting: AngleSetting) {
        setting.value = self
    }
}
