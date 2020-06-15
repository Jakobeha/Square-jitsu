//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TileLayer: Int, Comparable, CaseIterable, Codable {
    case air

    case background

    case solid
    case iceSolid

    case toxicEdge

    case entity

    // region pattern matching
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
        case .toxicEdge:
            return TileLayerSet.toxicEdge
        case .entity:
            return TileLayerSet.entity
        }
    }

    var doTilesOccupySides: Bool {
        switch self {
        case .toxicEdge:
            return true
        case .air, .background, .solid, .iceSolid, .entity:
            return false
        }
    }

    var isSolid: Bool {
        switch self {
        case .solid, .iceSolid:
            return true
        case .air, .background, .toxicEdge, .entity:
            return false
        }
    }

    static func layersCanOverlap(_ lhs: TileLayer, _ rhs: TileLayer) -> Bool {
        switch (lhs, rhs) {
        case (.air, _), (_, .air):
            return true
        case (.background, .background):
            return false
        case (.background, .solid), (.solid, .background), (.background, .iceSolid), (.iceSolid, .background):
            return false
        case (.background, .toxicEdge), (.toxicEdge, .background), (.background, .entity), (.entity, .background):
            return true
        case (.solid, .solid):
            return false
        case (.solid, .iceSolid), (.iceSolid, .solid), (.solid, .entity), (.entity, .solid):
            return false
        case (.solid, .toxicEdge), (.toxicEdge, .solid):
            return true
        case (.iceSolid, .iceSolid):
            return false
        case (.iceSolid, .entity), (.entity, .iceSolid):
            return false
        case (.iceSolid, .toxicEdge), (.toxicEdge, .iceSolid):
            return true
        case (.toxicEdge, .toxicEdge):
            return false
        case (.toxicEdge, .entity), (.entity, .toxicEdge):
            return false
        case (.entity, .entity):
            return false
        }
    }
    // endregion

    /// Whether rhs tiles are on top of lhs tiles
    static func <(lhs: TileLayer, rhs: TileLayer) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var zPosition: CGFloat {
        CGFloat(rawValue)
    }

    // region encoding and decoding
    var description: String { String(describing: self) }

    private static let layersByName: [String:TileLayer] = [String:TileLayer](
            uniqueKeysWithValues: allCases.map { layer in (key: layer.description, value: layer) }
    )

    init?(_ description: String) {
        if let layer = TileLayer.layersByName[description] {
            self = layer
        } else {
            return nil
        }
    }
    // endregion
}
