//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class View {
    /// Views need to update after cascading model updates,
    /// to prevent confusing display bugs
    static let observerPriority: Int = -1

    /// Used as a sanity check
    private(set) weak var parent: SKNode? = nil

    var hasParent: Bool { parent != nil }

    func placeIn(parent: SKNode) {
        assert(!hasParent, "already placed")
        self.parent = parent
    }

    func removeFromParent() {
        assert(hasParent, "not placed")
        parent = nil
    }
}
