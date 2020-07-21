//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TileLayer: Int, Comparable, CaseIterable, Codable {
    case air

    case background
    case backgroundDirectionBoost

    case solid
    case iceSolid

    case edge

    case free

    case collectible

    case entity

    // region pattern matching
    var toSet: TileLayerSet {
        switch self {
        case .air:
            return TileLayerSet.air
        case .background:
            return TileLayerSet.background
        case .backgroundDirectionBoost:
            return TileLayerSet.backgroundDirectionBoost
        case .solid:
            return TileLayerSet.solid
        case .iceSolid:
            return TileLayerSet.iceSolid
        case .edge:
            return TileLayerSet.edge
        case .free:
            return TileLayerSet.free
        case .collectible:
            return TileLayerSet.collectible
        case .entity:
            return TileLayerSet.entity
        }
    }

    var doTilesOccupySides: Bool {
        switch self {
        case .edge:
            return true
        case .air, .background, .backgroundDirectionBoost, .solid, .iceSolid, .free, .collectible, .entity:
            return false
        }
    }

    var isSolid: Bool {
        switch self {
        case .solid, .iceSolid, .edge:
            return true
        case .air, .background, .backgroundDirectionBoost, .free, .collectible, .entity:
            return false
        }
    }

    private static let layerOverlapDMatrix: [[Bool]] = [
        //                              .entity .collectible .free .edge .iceSolid .solid .backgroundDirectionBoost .background .air
        /* .air                      */ [true,  true,        true, true, true,     true,  true,                     true,       true],
        /* .background               */ [true,  true,        true, true, false,    false, true,                     false],
        /* .backgroundDirectionBoost */ [true,  true,        true, true, false,    false, false],
        /* .solid                    */ [false, false,       true, true, false,    false],
        /* .iceSolid                 */ [false, false,       true, true, false],
        /* .edge                     */ [true,  true,        true, false],
        /* .free                     */ [true,  true,        true],
        /* .collectible              */ [false, false],
        /* .entity                   */ [false]
    ]

    static func layersCanOverlap(_ lhs: TileLayer, _ rhs: TileLayer) -> Bool {
        lhs.rawValue < rhs.rawValue ?
                layerOverlapDMatrix[lhs.rawValue][TileLayer.allCases.count - 1 - rhs.rawValue] :
                layerOverlapDMatrix[rhs.rawValue][TileLayer.allCases.count - 1 - lhs.rawValue]
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
