//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Places earlier children above later ones
class ZStack: Stack {
    static func layout(children: [UXView]) -> [UXView] {
        var children = children
        for index in children.indices {
            children[index].topLeft = CGPoint.zero
            children[index].zPosition = CGFloat(children.count - index)
        }
        return children
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(ZStack.layout(children: children), width: width, height: height, topLeft: topLeft)
    }
}
