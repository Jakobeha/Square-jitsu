//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Stack: UXView {
    private var children: [UXView]
    private let width: CGFloat?
    private let height: CGFloat?

    let node: SKNode = SKNode()

    init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        self.children = children
        self.width = width
        self.height = height

        // For some reason self.topLeft doesn't work
        var position = topLeft
        // Invert the y for UX manually (this is bad coding, duplication)
        position.y = -position.y
        node.position = position

        for child in children {
            child.set(parent: node)
        }
    }

    var size: CGSize {
        CGSize(
            width: width ?? children.map { $0.bounds.maxX }.max() ?? 0,
            height: height ?? children.map { $0.bounds.maxY }.max() ?? 0
        )
    }

    func set(sceneSize: CGSize) {
        for index in children.indices {
            children[index].set(sceneSize: sceneSize)
        }
    }
}
