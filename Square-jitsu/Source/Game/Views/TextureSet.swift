//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TextureSet {
    case fromBaseName(String)

    subscript(name: String) -> SKTexture {
        switch self {
        case .fromBaseName(let baseName):
            let textureName = "\(baseName)_\(name)"
            return SKTexture(imageNamed: textureName)
        }
    }
}
