//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a 2D vector by selecting each number from a range
class CGSizeRangeSetting: SerialSetting {
    private let widthRange: ClosedRange<CGFloat>
    private let heightRange: ClosedRange<CGFloat>

    var value: CGSize

    init(width widthRange: ClosedRange<CGFloat>, height heightRange: ClosedRange<CGFloat>) {
        self.widthRange = widthRange
        self.heightRange = heightRange
        value = CGSize(width: widthRange.lowerBound, height: heightRange.lowerBound)
    }

    func decodeWellFormed(from json: JSON) throws {
        let vectorArray = try json.toArray()
        try DecodeSettingError.assertLengthOf(array: vectorArray, expected: 2)

        let width = try vectorArray[0].toCgFloat()
        let height = try vectorArray[1].toCgFloat()

        value = CGSize(width: width, height: height)
    }

    func encodeWellFormed() throws -> JSON {
        JSON([JSON(value.width), JSON(value.height)])
    }

    func validate() throws {
        if !widthRange.contains(value.width) {
            throw DecodeSettingError.outOfRange(minDesc: widthRange.lowerBound.description, maxDesc: widthRange.upperBound.description)
        }
        if !heightRange.contains(value.height) {
            throw DecodeSettingError.outOfRange(minDesc: heightRange.lowerBound.description, maxDesc: heightRange.upperBound.description)
        }
    }

    func decodeDynamically<T>() -> T { value as! T }
}

extension CGSize: SettingCodable {
    typealias AsSetting = CGSizeRangeSetting

    static func decode(from setting: CGSizeRangeSetting) -> CGSize {
        setting.value
    }

    func encode(to setting: CGSizeRangeSetting) {
        setting.value = self
    }
}
