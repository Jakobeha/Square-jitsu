//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TextureSet {
    case fromBaseName(String)

    var count: Int {
        switch self {
        case .fromBaseName(let baseName):
            return Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: baseName)!.count
        }
    }

    subscript(name: String) -> SKTexture {
        switch self {
        case .fromBaseName(let baseName):
            let textureName = "\(baseName)/\(name)"
            return SKTexture(imageNamed: textureName)
        }
    }

    subscript(nameAsIndex: Int) -> SKTexture {
        self[String(nameAsIndex)]
    }
}
