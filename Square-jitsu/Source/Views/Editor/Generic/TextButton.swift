//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TextButton: UXView {
    static let height: CGFloat = 32
    private static let fontName: String = Label.fontName
    private static let fontSize: CGFloat = Label.fontSize
    private static let fontColor: SKColor = Label.fontColor

    private var isPressed: Bool = false {
        didSet { backgroundNode.texture = Button.backgroundTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    private var isSelected: Bool {
        didSet { backgroundNode.texture = Button.backgroundTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    var isEnabled: Bool {
        didSet { updateForIsEnabled() }
    }

    private let width: CGFloat

    private let buttonNode: ButtonNode
    private let backgroundNode: SKSpriteNode
    private let textNode: SKLabelNode
    var node: SKNode { buttonNode }

    var size: CGSize {
        CGSize(width: width, height: TextButton.height)
    }

    init<Owner: AnyObject>(
        owner: Owner,
        text: String,
        width: CGFloat,
        isEnabled: Bool = true,
        isSelected: Bool = false,
        action: @escaping (Owner) -> ()
    ) {
        self.width = width
        let size = CGSize(width: width, height: TextButton.height)
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        backgroundNode = SKSpriteNode(
            texture: Button.backgroundTexture(isPressed: false, isSelected: isSelected),
            size: size
        )
        backgroundNode.centerRect = Button.backgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        textNode = SKLabelNode(text: text)
        textNode.fontName = TextButton.fontName
        textNode.fontSize = TextButton.fontSize
        textNode.fontColor = TextButton.fontColor
        textNode.horizontalAlignmentMode = .center
        textNode.verticalAlignmentMode = .center
        textNode.position = ConvertToUXCoords(size: size / 2).toPoint
        textNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha
        textNode.zPosition = 2
        buttonNode = ButtonNode(size: size)
        buttonNode.didPress.subscribe(observer: self, priority: .view) { [weak owner] _ in
            guard let owner = owner else {
                Logger.warn("text button pressed but its owner was deallocated, so it can't perform its action")
                return
            }

            action(owner)
        }
        buttonNode.addChild(backgroundNode)
        buttonNode.addChild(textNode)
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
        textNode.alpha = Button.foregroundAlpha(isEnabled: isEnabled)
    }

    func set(scene: SJScene) {}
}
