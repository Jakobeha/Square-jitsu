//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class RePosition: UXWrapperView, UXView {
    init(_ wrapped: UXView, left: CGFloat? = nil, top: CGFloat? = nil) {
        super.init(wrapped)
        if let left = left {
            wrapped.topLeft.x = left
        }
        if let top = top {
            wrapped.topLeft.y = top
        }
    }

    var topLeft: CGPoint {
        get { wrapped.topLeft }
        set { wrapped.topLeft = newValue }
    }

    var size: CGSize {
        get { wrapped.size }
    }
}
