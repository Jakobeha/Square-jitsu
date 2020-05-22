//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UXWrapperView: View {
    let wrapped: UXView

    init(_ wrapped: UXView) {
        self.wrapped = wrapped
    }

    final override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        wrapped.placeIn(parent: parent)
    }

    final override func removeFromParent() {
        super.removeFromParent()
        wrapped.removeFromParent()
    }
}
