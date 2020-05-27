//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class VStack: Stack {
    static func layout(children: [UXView]) -> [UXView] {
        var children = children
        for index in children.indices.dropFirst() {
            let prevChild = children[index - 1]
            children[index].topLeft.y = prevChild.bounds.maxY
        }
        return children
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(VStack.layout(children: children), width: width, height: height, topLeft: topLeft)
    }
}
