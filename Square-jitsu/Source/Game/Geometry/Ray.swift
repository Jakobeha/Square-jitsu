//
// Created by Jakob Hain on 6/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Ray {
    let start: CGPoint
    let direction: Angle

    /// Starting at the ray's start, then moving in the ray's direction by the given distance,
    /// will get to the returned point
    func positionAt(distance: CGFloat) -> CGPoint {
        start + CGPoint(magnitude: distance, directionFromOrigin: direction)
    }

    /// The line from the ray's start going in its direction with the given distance
    func cutoffAt(distance: CGFloat) -> LineSegment {
        LineSegment(start: start, end: positionAt(distance: distance))
    }
}
