//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LocationComponent: SingleSettingCodable, Codable {
    var position: CGPoint = CGPoint.nan
    var rotation: Angle = Angle.zero
    var radius: CGFloat

    var bounds: CGRect {
        CGRect(
                x: position.x - radius,
                y: position.y - radius,
                width: radius * 2,
                height: radius * 2
        )
    }

    /// Distance from the furthest point on this entity (assuming it's a circle) to the given point
    func distance(to point: CGPoint) -> CGFloat {
        max(0, (position - point).magnitude - radius)
    }

    /// Distance from the furthest point on this entity (assuming it's a circle) to the given line
    /// (distance from the closest point on the line)
    func distance(to line: LineSegment) -> CGFloat {
        max(0, line.getDistanceTo(point: position) - radius)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<LocationComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "radius": CGFloatRangeSetting(0...16)
        ], optionalFields: [:])
    }

    enum CodingKeys: String, CodingKey {
        case radius
    }
    // endregion
}
