//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Allows the user to select a 2D vector by selecting each number from a range
class CGPointRangeSetting: SerialSetting {
    private let xRange: ClosedRange<CGFloat>
    private let yRange: ClosedRange<CGFloat>

    var value: CGPoint

    init(x xRange: ClosedRange<CGFloat>, y yRange: ClosedRange<CGFloat>) {
        self.xRange = xRange
        self.yRange = yRange
        value = CGPoint(x: xRange.lowerBound, y: yRange.lowerBound)
    }

    func decodeWellFormed(from json: JSON) throws {
        let vectorArray = try json.toArray()
        try DecodeSettingError.assertLengthOf(array: vectorArray, expected: 2)

        let x = try vectorArray[0].toCgFloat()
        let y = try vectorArray[1].toCgFloat()

        value = CGPoint(x: x, y: y)
    }

    func encodeWellFormed() throws -> JSON {
        JSON([JSON(value.x), JSON(value.y)])
    }

    func validate() throws {
        if !xRange.contains(value.x) {
            throw DecodeSettingError.outOfRange(minDesc: xRange.lowerBound.description, maxDesc: xRange.upperBound.description)
        }
        if !yRange.contains(value.y) {
            throw DecodeSettingError.outOfRange(minDesc: yRange.lowerBound.description, maxDesc: yRange.upperBound.description)
        }
    }

    func decodeDynamically<T>() -> T { value as! T }
}

extension CGPoint: SettingCodable {
    typealias AsSetting = CGPointRangeSetting

    static func decode(from setting: CGPointRangeSetting) -> CGPoint {
        setting.value
    }

    func encode(to setting: CGPointRangeSetting) {
        setting.value = self
    }
}
