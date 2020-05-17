//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class BoolSetting: SerialSetting {
    var value: Bool = false

    init() {}

    func decodeWellFormed(from json: JSON) throws {
        value = try json.toBoolean()
    }

    func encodeWellFormed() throws -> JSON {
        JSON(value)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { value as! T }
}

extension Bool: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! BoolSetting).value = self
    }
}
