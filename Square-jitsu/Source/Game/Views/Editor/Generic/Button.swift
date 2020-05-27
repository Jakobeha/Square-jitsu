//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Button: UXView {
    private static let background: SKTexture = SKTexture(imageNamed: "UI/ButtonBackground")
    private static let backgroundPressed: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundPressed")
    private static let backgroundSelected: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundSelected")
    private static let backgroundTintSaturation: CGFloat = 0.25
    static let disabledForegroundAlpha: CGFloat = 0.5

    static let instantActionButtonTintHue: CGFloat = 0.32
    static let selectButtonTintHue: CGFloat = 0.54

    private static func backgroundNodeTintColor(tintHue: CGFloat?) -> SKColor {
        if let tintHue = tintHue {
            return SKColor(hue: tintHue, saturation: backgroundTintSaturation, brightness: 1, alpha: 1)
        } else {
            return SKColor.clear
        }
    }

    private static func backgroundNodeTexture(isPressed: Bool, isSelected: Bool) -> SKTexture {
        if isPressed {
            return backgroundPressed
        } else if isSelected {
            return backgroundSelected
        } else {
            return background
        }
    }

    private let buttonSize: ButtonSize

    private var isPressed: Bool = false {
        didSet { backgroundNode.texture = Button.backgroundNodeTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    private var isSelected: Bool {
        didSet { backgroundNode.texture = Button.backgroundNodeTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    var isEnabled: Bool {
        didSet { updateForIsEnabled() }
    }

    private let buttonNode: ButtonNode
    private let backgroundNode: SKSpriteNode
    private let foregroundNode: SKSpriteNode
    var node: SKNode { buttonNode }

    var size: CGSize { buttonSize.cgSize }

    init(textureName: String, size: ButtonSize = .medium, isEnabled: Bool = true, isSelected: Bool = false, tintHue: CGFloat? = nil, action: @escaping () -> ()) {
        buttonSize = size
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        let texture = SKTexture(imageNamed: textureName)
        backgroundNode = SKSpriteNode(
                texture: Button.backgroundNodeTexture(isPressed: false, isSelected: isSelected),
                color: Button.backgroundNodeTintColor(tintHue: tintHue),
                size: size.cgSize
        )
        if tintHue != nil {
            backgroundNode.colorBlendFactor = 1
        }
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        foregroundNode = SKSpriteNode(texture: texture, size: size.cgSize)
        foregroundNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha
        foregroundNode.anchorPoint = UXSpriteAnchor
        foregroundNode.zPosition = 1
        buttonNode = ButtonNode(
            size: buttonSize.cgSize,
            action: action
        )
        buttonNode.addChild(backgroundNode)
        buttonNode.addChild(foregroundNode)
        buttonNode.onTouchDown = { self.isPressed = true }
        buttonNode.onTouchUp = { self.isPressed = false }

        updateForIsEnabled()
    }

    private func updateForIsEnabled() {
        buttonNode.isEnabled = isEnabled
        foregroundNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha
    }

    func set(sceneSize: CGSize) {}
}
