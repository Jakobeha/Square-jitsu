//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TextureSetSetting: SerialSetting {
    private var baseName: String? = nil {
        didSet {
            if let baseName = baseName {
                textureSet = .fromBaseName(baseName)
            }
        }
    }

    fileprivate var textureSet: TextureSet? = nil

    func decodeWellFormed(from json: JSON) throws {
        // TODO: Make sure textures exist first (and throw if they don't) and support more formats (e.g. urls)
        baseName = try json.toString()
    }

    func encodeWellFormed() throws -> JSON {
        if let baseName = baseName {
            return JSON(baseName)
        } else {
            fatalError("TODO not implemented")
        }
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { textureSet! as! T }
}

extension TextureSet: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TextureSetSetting).textureSet = self
    }
}
