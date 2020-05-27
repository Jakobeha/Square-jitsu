//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct ReLayout: UXView {
    private var wrapped: UXView
    private let width: CGFloat?
    private let height: CGFloat?

    init(_ wrapped: UXView, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.wrapped = wrapped
        self.width = width
        self.height = height
    }

    var node: SKNode { wrapped.node }

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

    mutating func set(sceneSize: CGSize) {
        wrapped.set(sceneSize: sceneSize)
    }
}
