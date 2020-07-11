//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TextureLocation: Decodable, Encodable, LosslessStringConvertible {
    case withName(String)

    static let missing: TextureLocation = .withName("Missing")

    var texture: SKTexture {
        switch self {
        case .withName(let name):
            return SKTexture(imageNamed: name)
        }
    }

    // region encoding and decoding
    private static func validate(textureName: String) throws {
        let textureExists = Bundle.main.url(forResource: textureName, withExtension: "png") != nil
        if !textureExists {
            throw InvalidTextureLocationError.namedNotFound(textureName: textureName)
        }
    }

    var description: String {
        switch self {
        case .withName(let name):
            return name
        }
    }

    init(asString: String) throws {
        // TODO: Support more formats (e.g. urls)
        try TextureLocation.validate(textureName: asString)
        self = .withName(asString)
    }

    init?(_ description: String) {
        do {
            try self.init(asString: description)
        } catch {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let asString = try container.decode(String.self)
        do {
            self = try TextureLocation(asString: asString)
        } catch {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    // endregion
}
