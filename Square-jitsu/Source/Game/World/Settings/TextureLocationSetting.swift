//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TextureLocationSetting: SerialSetting {
    fileprivate var textureLocation: TextureLocation = TextureLocation.missing

    func decodeWellFormed(from json: JSON) throws {
        let jsonString = try json.toString()
        textureLocation = try TextureLocation(asString: jsonString)
    }

    func encodeWellFormed() throws -> JSON {
        JSON(textureLocation.description)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { textureLocation as! T }
}

extension TextureLocation: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TextureLocationSetting).textureLocation = self
    }
}
