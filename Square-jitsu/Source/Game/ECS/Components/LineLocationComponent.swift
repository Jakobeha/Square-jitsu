//
// Created by Jakob Hain on 6/2/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// The entity's shape is actually a line segment,
/// so a point + radius (as in a regular location component) isn't good enough
struct LineLocationComponent: SingleSettingCodable, Codable {
    var position: LineSegment = LineSegment.nan
    var thickness: CGFloat

    var startEndpointHit: LineCastHit? = nil
    var endEndpointHit: LineCastHit? = nil

    var adjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> {
        DenseEnumMap { side in
            var adjacentPositionsForSide: Set<WorldTilePos> = []
            if let startEndpointHit = startEndpointHit,
               startEndpointHit.hitSide == side {
                adjacentPositionsForSide.insert(startEndpointHit.pos3D.pos)
            }
            if let endEndpointHit = endEndpointHit,
               endEndpointHit.hitSide == side {
                adjacentPositionsForSide.insert(endEndpointHit.pos3D.pos)
            }
            return adjacentPositionsForSide
        }
    }

    /// Distance from the furthest point on this entity (assuming it's a circle) to the given point
    func distance(to point: CGPoint) -> CGFloat {
        max(0, position.getDistanceTo(point: point) - thickness)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<LineLocationComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "thickness": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case thickness
    }
    // endregion
}
