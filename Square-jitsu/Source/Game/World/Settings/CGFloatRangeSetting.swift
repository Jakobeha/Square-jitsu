//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a number from a range
class CGFloatRangeSetting: SerialSetting {
    private let range: ClosedRange<CGFloat>

    var value: CGFloat

    init(_ range: ClosedRange<CGFloat>) {
        self.range = range
        value = CGFloat.nan
    }

    func decodeWellFormed(from json: JSON) throws {
        value = try json.toCgFloat()
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

extension CGFloat: SettingCodable {
    typealias AsSetting = CGFloatRangeSetting

    static func decode(from setting: CGFloatRangeSetting) -> CGFloat {
        setting.value
    }

    func encode(to setting: CGFloatRangeSetting) {
        setting.value = self
    }
}
