//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class StringSetting: SerialSetting {
    var value: String = ""

    func decodeWellFormed(from json: JSON) throws {
        value = try json.toString()
    }

    func encodeWellFormed() throws -> JSON {
        JSON(value)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { value as! T }
}

extension String: SettingCodable {
    typealias AsSetting = StringSetting

    static func decode(from setting: StringSetting) -> String {
        setting.value
    }

    func encode(to setting: StringSetting) {
        setting.value = self
    }
}
