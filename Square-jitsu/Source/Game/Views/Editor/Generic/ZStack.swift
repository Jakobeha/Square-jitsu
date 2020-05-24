//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Places earlier children above later ones
class ZStack: Stack {
    static func layout(wrappedChildren: [GenNodeView & UXView]) {
        for (index, child) in wrappedChildren.enumerated() {
            child.node_gen.zPosition = CGFloat(-index)
        }
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        let wrappedChildren = children.map(UXNodeWrapperView.wrapIfNotNode)
        super.init(wrappedChildren, width: width, height: height, topLeft: topLeft)
        ZStack.layout(wrappedChildren: wrappedChildren)
    }
}
