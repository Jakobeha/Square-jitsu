//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Button: UXNodeView<ButtonNode>, UXView {
    private static let background: SKTexture = SKTexture(imageNamed: "UI/ButtonBackground")
    private static let backgroundPressed: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundPressed")
    private static let backgroundSelected: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundSelected")
    static let disabledForegroundAlpha: CGFloat = 0.5

    private let buttonSize: ButtonSize

    private var isPressed: Bool = false {
        didSet { backgroundNode.texture = backgroundNodeTexture }
    }
    private var isSelected: Bool {
        didSet { backgroundNode.texture = backgroundNodeTexture }
    }
    var isEnabled: Bool {
        didSet { foregroundNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha }
    }

    private let backgroundNode: SKSpriteNode
    private let foregroundNode: SKSpriteNode

    private var backgroundNodeTexture: SKTexture {
        if isPressed {
            return Button.backgroundPressed
        } else if isSelected {
            return Button.backgroundSelected
        } else {
            return Button.background
        }
    }

    var size: CGSize { buttonSize.cgSize }

    init(textureName: String, size: ButtonSize = .medium, isEnabled: Bool = true, isSelected: Bool = false, action: @escaping () -> ()) {
        buttonSize = size
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        let texture = SKTexture(imageNamed: textureName)
        backgroundNode = SKSpriteNode(texture: Button.background, size: size.cgSize)
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        foregroundNode = SKSpriteNode(texture: texture, size: size.cgSize)
        foregroundNode.anchorPoint = UXSpriteAnchor
        foregroundNode.zPosition = 1
        super.init(node: ButtonNode(
            size: buttonSize.cgSize,
            action: action
        ))
        node.addChild(backgroundNode)
        node.addChild(foregroundNode)
        node.onTouchDown = { self.isPressed = true }
        node.onTouchUp = { self.isPressed = false }
    }
}
