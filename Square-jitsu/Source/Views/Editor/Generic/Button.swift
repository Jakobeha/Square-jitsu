//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Button: UXView {
    static let background: SKTexture = SKTexture(imageNamed: "UI/ButtonBackground")
    static let backgroundPressed: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundPressed")
    static let backgroundSelected: SKTexture = SKTexture(imageNamed: "UI/ButtonBackgroundSelected")
    static let backgroundCenterRect: CGRect = CGRect(origin: CGPoint(x: 0.5, y: 0.5), size: CGSize.zero)
    private static let backgroundTintSaturation: CGFloat = 0.25
    static let disabledForegroundAlpha: CGFloat = 0.5
    private static let rouletteNextItemSizeMultiplier: CGFloat = 0.5
    private static let rouletteNextItemAlphaMultiplier: CGFloat = 0.5

    static let instantActionButtonTintHue: CGFloat = 0.32

    static func backgroundTintColor(tintHue: CGFloat?) -> SKColor {
        if let tintHue = tintHue {
            return SKColor(hue: tintHue, saturation: backgroundTintSaturation, brightness: 1, alpha: 1)
        } else {
            return SKColor.clear
        }
    }

    static func backgroundTexture(isPressed: Bool, isSelected: Bool) -> SKTexture {
        if isPressed {
            return backgroundPressed
        } else if isSelected {
            return backgroundSelected
        } else {
            return background
        }
    }

    static func foregroundAlpha(isEnabled: Bool) -> CGFloat {
        isEnabled ? 1 : Button.disabledForegroundAlpha
    }

    private let buttonSize: ButtonSize

    private var isPressed: Bool = false {
        didSet { backgroundNode.texture = Button.backgroundTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    private var isSelected: Bool {
        didSet { backgroundNode.texture = Button.backgroundTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    var isEnabled: Bool {
        didSet { updateForIsEnabled() }
    }

    private let buttonNode: ButtonNode
    private let backgroundNode: SKSpriteNode
    private let rouletteNextItemNode: SKSpriteNode?
    private let foregroundNode: SKSpriteNode
    var node: SKNode { buttonNode }

    var size: CGSize { buttonSize.cgSize }

    convenience init<Owner: AnyObject>(
        owner: Owner,
        textureName: String,
        rouletteNextItemTextureName: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isSelected: Bool = false,
        tintHue: CGFloat? = nil,
        action: @escaping (Owner) -> ()
    ) {
        self.init(
            owner: owner,
            texture: SKTexture(imageNamed: textureName),
            rouletteNextItemTextureName: rouletteNextItemTextureName,
            size: size,
            isEnabled: isEnabled,
            isSelected: isSelected,
            tintHue: tintHue,
            action: action
        )
    }

    init<Owner: AnyObject>(
        owner: Owner,
        texture: SKTexture,
        rouletteNextItemTextureName: String? = nil,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isSelected: Bool = false,
        tintHue: CGFloat? = nil,
        action: @escaping (Owner) -> ()
    ) {
        buttonSize = size
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        backgroundNode = SKSpriteNode(
            texture: Button.backgroundTexture(isPressed: false, isSelected: isSelected),
            color: Button.backgroundTintColor(tintHue: tintHue),
            size: size.cgSize
        )
        if tintHue != nil {
            backgroundNode.colorBlendFactor = 1
        }
        backgroundNode.centerRect = Button.backgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        if let rouletteNextItemTextureName = rouletteNextItemTextureName {
            let rouletteNextItemTexture = SKTexture(imageNamed: rouletteNextItemTextureName)
            rouletteNextItemNode = SKSpriteNode(texture: rouletteNextItemTexture, size: size.cgSize * Button.rouletteNextItemSizeMultiplier)
            rouletteNextItemNode!.alpha = Button.foregroundAlpha(isEnabled: isEnabled) * Button.rouletteNextItemAlphaMultiplier
            rouletteNextItemNode!.anchorPoint = UXSpriteAnchor
            rouletteNextItemNode!.position = ConvertToUXCoords(point: (size.cgSize * (1 - Button.rouletteNextItemSizeMultiplier)).toPoint)
            rouletteNextItemNode!.zPosition = 1
        } else {
            rouletteNextItemNode = nil
        }
        foregroundNode = SKSpriteNode(texture: texture, size: size.cgSize)
        foregroundNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha
        foregroundNode.anchorPoint = UXSpriteAnchor
        foregroundNode.zPosition = 2
        buttonNode = ButtonNode(size: buttonSize.cgSize)
        buttonNode.didPress.subscribe(observer: self, priority: .view) { [weak owner] _ in
            guard let owner = owner else {
                Logger.warn("button pressed but it's owner was deallocated, so it can't perform its action")
                return
            }

            action(owner)
        }
        buttonNode.addChild(backgroundNode)
        if let rouletteNextItemNode = rouletteNextItemNode {
            buttonNode.addChild(rouletteNextItemNode)
        }
        buttonNode.addChild(foregroundNode)
        buttonNode.didTouchDown.subscribe(observer: self, priority: .view) { (self) in
            self.isPressed = true
        }
        buttonNode.didTouchUp.subscribe(observer: self, priority: .view) { (self) in
            self.isPressed = false
        }

        updateForIsEnabled()
    }

    private func updateForIsEnabled() {
        buttonNode.isEnabled = isEnabled
        foregroundNode.alpha = Button.foregroundAlpha(isEnabled: isEnabled)
        rouletteNextItemNode?.alpha = Button.foregroundAlpha(isEnabled: isEnabled) * Button.rouletteNextItemAlphaMultiplier
    }

    func set(scene: SJScene) {}
}
