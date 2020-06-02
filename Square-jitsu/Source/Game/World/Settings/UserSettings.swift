//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Settings which may change on different devices even in the same world.
/// This is a mutable class, values are subject to change mid-game.
class UserSettings {
    var minPrimarySwipeSpeed: CGFloat = 36
    var minPrimarySwipeDistance: CGFloat = 72

    var panMultiplierFromScreenOffsetToWorldOffset: CGFloat = 4
    /// When the user is performing a select / move action in the editor
    /// and their finger is near the edge of the screen, the editor will pan.
    /// Specifically, the editor will pan with the speed of the last gradient point
    /// where their finger is closer to the edge than its cutoff distance
    var edgePanGradient: [EdgePanGradientPoint] = [
        EdgePanGradientPoint(distanceCutoff: 96, speedInPixelsPerSecond: 64),
        EdgePanGradientPoint(distanceCutoff: 64, speedInPixelsPerSecond: 128),
        EdgePanGradientPoint(distanceCutoff: 40, speedInPixelsPerSecond: 512),
        EdgePanGradientPoint(distanceCutoff: 16, speedInPixelsPerSecond: 1024)
    ]

    var screenSize: CGSize = CGSize.zero
}
