//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class HStack: Stack {
    static func layout(children: [UXView]) {
        for (child, prevChild) in zip(children.dropFirst(), children) {
            child.topLeft.x = prevChild.bounds.maxX
        }
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(children, width: width, height: height, topLeft: topLeft)
        HStack.layout(children: children)
    }
}
