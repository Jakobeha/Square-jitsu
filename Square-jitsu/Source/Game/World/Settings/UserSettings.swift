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

    var screenSize: CGSize = CGSize.zero
}
