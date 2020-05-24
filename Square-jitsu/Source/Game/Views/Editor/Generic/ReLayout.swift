//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ReLayout: UXWrapperView, UXView {
    let width: CGFloat?
    let height: CGFloat?

    init(_ wrapped: UXView, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
        super.init(wrapped)
    }

    var topLeft: CGPoint {
        get { wrapped.topLeft }
        set { wrapped.topLeft = newValue }
    }

    var size: CGSize {
        get {
            var size = wrapped.size
            if let width = width {
                size.width = width
            }
            if let height = height {
                size.height = height
            }
            return size
        }
    }
}
