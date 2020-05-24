//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class VStack: Stack {
    static func layout(children: [UXView]) {
        for (child, prevChild) in zip(children.dropFirst(), children) {
            child.topLeft.y = prevChild.bounds.maxY
        }
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(children, width: width, height: height, topLeft: topLeft)
        VStack.layout(children: children)
    }
}
