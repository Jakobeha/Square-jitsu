//
// Created by Jakob Hain on 5/30/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension SKTexture {
    static func withFilterModeNearest(textureName: String) -> SKTexture {
        let texture = SKTexture(imageNamed: textureName)
        texture.filteringMode = .nearest
        return texture
    }
}
