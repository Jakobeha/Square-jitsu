//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct RePosition: UXView {
    private var wrapped: UXView

    init(_ wrapped: UXView, left: CGFloat? = nil, top: CGFloat? = nil) {
        self.wrapped = wrapped

        if let left = left {
            topLeft.x = left
        }
        if let top = top {
            topLeft.y = top
        }
    }

    var node: SKNode { wrapped.node }

    var size: CGSize {
        get { wrapped.size }
    }

    mutating func set(scene: SJScene) {
        wrapped.set(scene: scene)
    }
}
