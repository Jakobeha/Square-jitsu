//
// Created by Jakob Hain on 5/23/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Repositions a UXView to cover the entire scene
class UXTopLevelView: View {
    private var child: UXView

    var zPosition: CGFloat {
        get { child.zPosition }
        set { child.zPosition = newValue }
    }

    init(child: UXView, sceneSize: CGSize) {
        var child = child
        child.topLeft = CGPoint(x: 0, y: -sceneSize.height)
        child.set(sceneSize: sceneSize)
        self.child = child
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        child.set(parent: parent)
    }

    override func removeFromParent() {
        super.removeFromParent()
        child.set(parent: nil)
    }
}
