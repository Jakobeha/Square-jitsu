//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a number from a range
class TimeRangeSetting: SerialSetting {
    private let range: ClosedRange<TimeInterval>

    var value: TimeInterval

    init(_ range: ClosedRange<TimeInterval>) {
        self.range = range
        value = range.lowerBound
    }

    func decodeWellFormed(from json: JSON) throws {
        value = try json.toTimeInterval()
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

extension TimeInterval: SettingCodable {
    typealias AsSetting = TimeRangeSetting

    static func decode(from setting: TimeRangeSetting) -> TimeInterval {
        setting.value
    }

    func encode(to setting: TimeRangeSetting) {
        setting.value = self
    }
}
