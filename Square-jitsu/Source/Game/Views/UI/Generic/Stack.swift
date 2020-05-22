//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Stack: UXNodeView<SKNode>, UXView {
    private let children: [UXView]
    private let width: CGFloat?
    private let height: CGFloat?

    init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        self.children = children
        self.width = width
        self.height = height

        super.init(node: SKNode())
        self.topLeft = topLeft
        for child in children {
            child.placeIn(parent: node)
        }
    }

    var size: CGSize {
        CGSize(
            width: width ?? children.map { $0.bounds.maxX }.max() ?? 0,
            height: height ?? children.map { $0.bounds.maxY }.max() ?? 0
        )
    }
}
