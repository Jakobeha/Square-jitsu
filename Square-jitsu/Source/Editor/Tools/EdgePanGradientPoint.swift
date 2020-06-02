//
// Created by Jakob Hain on 5/31/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct EdgePanGradientPoint {
    /// Minimum touch distance from the edge of the screen to start panning at this speed
    let distanceCutoff: CGFloat
    /// Speed which the editor will pan after the distance cutoff.
    /// If the distance cutoff of the next gradient point is reached,
    /// the editor will pan at that gradient's speed instead
    /// This is in pixels per second, *not* tiles per second,
    /// because if the tiles are smaller we don't necessarily want to pan slower.
    let speedInPixelsPerSecond: CGFloat
}
