//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TileLayer: Int {
    case air
    case background
    case foreground
    case entity

    var zPosition: CGFloat {
        CGFloat(rawValue)
    }

    static func layersCanOverlap(_ lhs: TileLayer, _ rhs: TileLayer) -> Bool {
        switch (lhs, rhs) {
        case (.air, _), (_, .air):
            return true
        case (.background, .background):
            return false
        case (.background, .foreground), (.foreground, .background):
            return false
        case (.background, .entity), (.entity, .background):
            return true
        case (.foreground, .foreground):
            return false
        case (.foreground, .entity), (.entity, .foreground):
            return false
        case (.entity, .entity):
            return false
        }
    }
}
