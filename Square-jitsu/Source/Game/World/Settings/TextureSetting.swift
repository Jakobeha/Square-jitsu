//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TextureSetting: SerialSetting {
    private var textureName: String? = nil {
        didSet {
            if let textureName = textureName {
                texture = SKTexture(imageNamed: textureName)
            }
        }
    }

    fileprivate var texture: SKTexture? = nil

    func decodeWellFormed(from json: JSON) throws {
        // TODO: Make sure texture exists first (and throw if it doesn't) and support more formats (e.g. urls)
        textureName = try json.toString()
    }

    func encodeWellFormed() throws -> JSON {
        if let textureName = textureName {
            return JSON(textureName)
        } else {
            fatalError("TODO not implemented")
        }
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { texture! as! T }
}

extension SKTexture: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TextureSetting).texture = self
    }
}
