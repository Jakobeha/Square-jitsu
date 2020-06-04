//
// Created by Jakob Hain on 6/2/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LineLocationComponent: SettingCodableByCodable, Codable {
    var position: Line = Line.nan
    var thickness: CGFloat

    var startEndpointHit: LineCastHit? = nil
    var endEndpointHit: LineCastHit? = nil

    /// Distance from the furthest point on this entity (assuming it's a circle) to the given point
    func distance(to point: CGPoint) -> CGFloat {
        max(0, position.getDistanceTo(point: point) - thickness)
    }

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case thickness
    }
    // endregion
}
