//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class HStack: Stack {
    static func layout(children: [UXView]) -> [UXView] {
        var children = children
        if !children.isEmpty {
            children[0].topLeft = CGPoint.zero
        }
        for index in children.indices.dropFirst() {
            let prevChild = children[index - 1]
            children[index].topLeft = CGPoint(x: prevChild.bounds.maxX, y: 0)
        }
        return children
    }

    override init(_ children: [UXView], width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(HStack.layout(children: children), width: width, height: height, topLeft: topLeft)
    }
}
