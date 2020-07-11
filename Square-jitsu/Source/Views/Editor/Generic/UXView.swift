//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

let UXSpriteAnchor: CGPoint = CGPoint(x: 0, y: 1)

func ConvertToUXCoords(point: CGPoint) -> CGPoint {
    CGPoint(x: point.x, y: -point.y)
}

func ConvertFromUXCoords(point: CGPoint) -> CGPoint {
    CGPoint(x: point.x, y: -point.y)
}

func ConvertToUXCoords(size: CGSize) -> CGSize {
    CGSize(width: size.width, height: -size.height)
}

func ConvertToUXCoords(rect: CGRect) -> CGRect {
    CGRect(
        origin: CGPoint(x: rect.origin.y, y: -rect.origin.y - rect.size.height),
        size: rect.size
    )
}

protocol UXView {
    /// If either axis is infinity, that means we stretch as much as possible within the screen bounds
    var size: CGSize { get }

    var node: SKNode { get }

    mutating func set(sceneSize: CGSize)
}

extension UXView {
    var topLeft: CGPoint {
        get { ConvertToUXCoords(point: node.position) }
        set { node.position = ConvertToUXCoords(point: newValue) }
    }
    var zPosition: CGFloat {
        get { node.zPosition }
        set { node.zPosition = newValue}
    }

    var bounds: CGRect { CGRect(origin: topLeft, size: size) }

    func set(parent: SKNode?) {
        if node.parent != nil {
            node.removeFromParent()
        }
        if let parent = parent {
            parent.addChild(node)
        }
    }
}