//
// Created by Jakob Hain on 5/23/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Repositions a UXView to cover the entire scene
class UXTopLevelView: View {
    private let child: UXView

    init(child: UXView, sceneSize: CGSize) {
        self.child = child
        child.topLeft = CGPoint(x: 0, y: -sceneSize.height)
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        child.placeIn(parent: parent)
    }

    override func removeFromParent() {
        super.removeFromParent()
        child.removeFromParent()
    }
}
