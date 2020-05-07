//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class View {
    /// Used as a sanity check
    private var isPlaced: Bool = false

    func placeIn(parent: SKNode) {
        assert(!isPlaced, "already placed")
        isPlaced = true
    }

    func removeFromParent() {
        assert(isPlaced, "not placed")
        isPlaced = false
    }
}
