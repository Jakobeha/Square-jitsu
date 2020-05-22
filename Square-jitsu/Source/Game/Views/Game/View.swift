//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class View {
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
