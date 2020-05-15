//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ColorSetting: SerialSetting {
    var hue: CGFloat = CGFloat.nan
    var saturation: CGFloat = CGFloat.nan
    var brightness: CGFloat = CGFloat.nan
    var alpha: CGFloat = CGFloat.nan

    var color: SKColor {
        get { SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha) }
        set { newValue.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) }
    }

    func decodeWellFormed(from json: JSON) throws {
        let jsonDict = try json.toDictionary()
        try DecodeSettingError.assertKeysIn(dictionary: jsonDict, requiredKeys: ["hue", "saturation", "brightness"], optionalKeys: ["alpha"])

        hue = try jsonDict["hue"]!.toCgFloat()
        saturation = try jsonDict["saturation"]!.toCgFloat()
        brightness = try jsonDict["brightness"]!.toCgFloat()
        alpha = try jsonDict["alpha"]?.toCgFloat() ?? 1
    }

    func encodeWellFormed() throws -> JSON {
        if alpha != 1 {
            return JSON([
                "hue": JSON(hue),
                "saturation": JSON(saturation),
                "brightness": JSON(brightness)
            ])
        } else {
            return JSON([
                "hue": JSON(hue),
                "saturation": JSON(saturation),
                "brightness": JSON(brightness),
                "alpha": JSON(alpha)
            ])
        }
    }

    func validate() throws {
        if hue < 0 || hue > 1 {
            throw DecodeSettingError.badField(fieldName: "hue", error: DecodeSettingError.outOfRange(minDesc: "0", maxDesc: "1"))
        }
        if saturation < 0 || saturation > 1 {
            throw DecodeSettingError.badField(fieldName: "saturation", error: DecodeSettingError.outOfRange(minDesc: "0", maxDesc: "1"))
        }
        if brightness < 0 || brightness > 1 {
            throw DecodeSettingError.badField(fieldName: "brightness", error: DecodeSettingError.outOfRange(minDesc: "0", maxDesc: "1"))
        }
        if alpha < 0 || alpha > 1 {
            throw DecodeSettingError.badField(fieldName: "alpha", error: DecodeSettingError.outOfRange(minDesc: "0", maxDesc: "1"))
        }
    }

    func decodeDynamically<T>() -> T { color as! T }
}

extension SKColor: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! ColorSetting).color = self
    }
}
