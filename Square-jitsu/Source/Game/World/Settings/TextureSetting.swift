//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TextureSetting: SerialSetting {
    private var textureName: String = "Misc/Missing" {
        didSet {
            texture = SKTexture(imageNamed: textureName)
        }
    }

    fileprivate var texture: SKTexture? = nil

    func decodeWellFormed(from json: JSON) throws {
        let jsonString = try json.toString()
        let textureLocation = try TextureLocation(asString: jsonString)
        texture = textureLocation.texture
    }

    func encodeWellFormed() throws -> JSON {
        JSON(textureName)
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { texture as! T }
}

extension SKTexture: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TextureSetting).texture = self
    }
}
