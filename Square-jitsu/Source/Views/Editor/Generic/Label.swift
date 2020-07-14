//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Label: UXView {
    static let fontName: String = "Helvetica"
    static let fontSize: CGFloat = 14
    static let fontColor: SKColor = SKColor.black
    private static let estimatedCharacterWidthMultiplier: CGFloat = 0.5

    private let text: String

    private let labelNode: SKLabelNode
    var node: SKNode { labelNode }

    /// The rough size of the text
    var size: CGSize {
        CGSize(width: Label.fontSize * Label.estimatedCharacterWidthMultiplier * CGFloat(text.count), height: Label.fontSize)
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

    func set(scene: SJScene) {}
}
