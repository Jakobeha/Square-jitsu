//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class HStack: Stack {
    static func layout(children: [UXView], spacing: CGFloat) -> [UXView] {
        var children = children
        if !children.isEmpty {
            children[0].topLeft = CGPoint.zero
        }
        for index in children.indices.dropFirst() {
            let prevChild = children[index - 1]
            children[index].topLeft = CGPoint(x: prevChild.bounds.maxX + spacing, y: 0)
        }
        return children
    }

    init(_ children: [UXView], spacing: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil, topLeft: CGPoint = CGPoint.zero) {
        super.init(HStack.layout(children: children, spacing: spacing), width: width, height: height, topLeft: topLeft)
    }
}
