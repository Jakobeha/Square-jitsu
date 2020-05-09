//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TileLayer: Int {
    case air
    case background
    case solid
    case entity

    var toSet: TileLayerSet {
        switch self {
        case .air:
            return TileLayerSet.air
        case .background:
            return TileLayerSet.background
        case .solid:
            return TileLayerSet.solid
        case .entity:
            return TileLayerSet.entity
        }
    }

    var zPosition: CGFloat {
        CGFloat(rawValue)
    }

    static func layersCanOverlap(_ lhs: TileLayer, _ rhs: TileLayer) -> Bool {
        switch (lhs, rhs) {
        case (.air, _), (_, .air):
            return true
        case (.background, .background):
            return false
        case (.background, .solid), (.solid, .background):
            return false
        case (.background, .entity), (.entity, .background):
            return true
        case (.solid, .solid):
            return false
        case (.solid, .entity), (.entity, .solid):
            return false
        case (.entity, .entity):
            return false
        }
    }
}
