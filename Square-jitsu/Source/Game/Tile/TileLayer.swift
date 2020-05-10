//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TileLayer: Int {
    case air

    case background

    case solid
    case iceSolid

    case toxic

    case entity

    var toSet: TileLayerSet {
        switch self {
        case .air:
            return TileLayerSet.air
        case .background:
            return TileLayerSet.background
        case .solid:
            return TileLayerSet.solid
        case .iceSolid:
            return TileLayerSet.iceSolid
        case .toxic:
            return TileLayerSet.toxic
        case .entity:
            return TileLayerSet.entity
        }
    }

    var isSolid: Bool {
        switch self {
        case .solid, .iceSolid:
            return true
        case .air, .background, .toxic, .entity:
            return false
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
        case (.background, .solid), (.solid, .background), (.background, .iceSolid), (.iceSolid, .background):
            return false
        case (.background, .toxic), (.toxic, .background), (.background, .entity), (.entity, .background):
            return true
        case (.solid, .solid):
            return false
        case (.solid, .iceSolid), (.iceSolid, .solid), (.solid, .entity), (.entity, .solid):
            return false
        case (.solid, .toxic), (.toxic, .solid):
            return true
        case (.iceSolid, .iceSolid):
            return false
        case (.iceSolid, .entity), (.entity, .iceSolid):
            return false
        case (.iceSolid, .toxic), (.toxic, .iceSolid):
            return true
        case (.toxic, .toxic):
            return false
        case (.toxic, .entity), (.entity, .toxic):
            return false
        case (.entity, .entity):
            return false
        }
    }
}
