//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum TileLayer {
    case air
    case background
    case foreground
    case spawn

    static func layersCanOverlap(_ lhs: TileLayer, _ rhs: TileLayer) -> Bool {
        switch (lhs, rhs) {
        case (.air, _), (_, .air):
            return true
        case (.background, .background):
            return false
        case (.background, .foreground), (.foreground, .background):
            return false
        case (.background, .spawn), (.spawn, .background):
            return true
        case (.foreground, .foreground):
            return false
        case (.foreground, .spawn), (.spawn, .foreground):
            return false
        case (.spawn, .spawn):
            return false
        }
    }
}
