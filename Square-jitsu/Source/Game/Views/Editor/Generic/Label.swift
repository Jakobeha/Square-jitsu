//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Label: UXView {
    private static let fontName: String = "Helvetica"
    private static let fontSize: CGFloat = 14
    private static let fontColor: SKColor = SKColor.black

    private let text: String

    private let labelNode: SKLabelNode
    var node: SKNode { labelNode }

    var size: CGSize {
        CGSize(width: 0, height: Label.fontSize)
    }

    init(text: String) {
        self.text = text

        labelNode = SKLabelNode(text: text)
        labelNode.fontName = Label.fontName
        labelNode.fontSize = Label.fontSize
        labelNode.fontColor = Label.fontColor
        // Position for UX coordinates
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .top
    }

    func set(sceneSize: CGSize) {}
}
