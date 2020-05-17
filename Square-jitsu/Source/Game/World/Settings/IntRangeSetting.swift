//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a number from a range
class IntRangeSetting: SerialSetting {
    private let range: ClosedRange<Int>

    var value: Int

    init(_ range: ClosedRange<Int>) {
        self.range = range
        value = range.lowerBound
    }

    func decodeWellFormed(from json: JSON) throws {
        value = try json.toInt()
    }

    func encodeWellFormed() throws -> JSON {
        JSON(value)
    }

    func validate() throws {
        if !range.contains(value) {
            throw DecodeSettingError.outOfRange(minDesc: range.lowerBound.description, maxDesc: range.upperBound.description)
        }
    }

    func decodeDynamically<T>() -> T { value as! T }
}

extension Int: SettingCodable {
    typealias AsSetting = IntRangeSetting

    static func decode(from setting: IntRangeSetting) -> Int {
        setting.value
    }

    func encode(to setting: IntRangeSetting) {
        setting.value = self
    }
}
