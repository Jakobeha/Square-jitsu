//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileButton: UXView {
    private static let background: SKTexture = SKTexture(imageNamed: "UI/CheckerBackground")
    private static let pressedBorder: SKTexture = SKTexture(imageNamed: "UI/TileButtonPressedBorder")
    private static let selectedBorder: SKTexture = SKTexture(imageNamed: "UI/TileButtonSelectedBorder")
    private static let disabledAlpha: CGFloat = Button.disabledForegroundAlpha

    private static func borderNodeTexture(isPressed: Bool, isSelected: Bool) -> SKTexture? {
        if isPressed {
            return pressedBorder
        } else if isSelected {
            return selectedBorder
        } else {
            return nil
        }
    }

    private var isPressed: Bool = false {
        didSet { borderNode.texture = TileButton.borderNodeTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    private var isSelected: Bool {
        didSet { borderNode.texture = TileButton.borderNodeTexture(isPressed: isPressed, isSelected: isSelected) }
    }
    var isEnabled: Bool {
        didSet { updateForIsEnabled() }
    }

    private let buttonNode: ButtonNode
    private let backgroundNode: SKSpriteNode
    private let tilePreviewNode: SKNode?
    private let entityPreviewNode: SKNode?
    private let borderNode: SKSpriteNode
    var node: SKNode { buttonNode }

    var size: CGSize { ButtonSize.tile.cgSize }

    init<Owner: AnyObject>(owner: Owner, tileType: TileType, settings: WorldSettings, isEnabled: Bool = true, isSelected: Bool = false, action: @escaping (Owner) -> ()) {
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        backgroundNode = SKSpriteNode(texture: TileButton.background, size: ButtonSize.tile.cgSize)
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        tilePreviewNode = settings.tileViewTemplates[tileType]?.generatePreviewNode(tileType: tileType, settings: settings, size: ButtonSize.tile.cgSize)
        tilePreviewNode?.zPosition = 1
        entityPreviewNode = settings.entityViewTemplates[tileType]?.generatePreviewNode(size: ButtonSize.tile.cgSize, settings: settings)
        entityPreviewNode?.zPosition = 2
        borderNode = SKSpriteNode(texture: TileButton.borderNodeTexture(isPressed: isPressed, isSelected: isSelected), size: ButtonSize.tile.cgSize)
        borderNode.anchorPoint = UXSpriteAnchor
        borderNode.zPosition = 3

        buttonNode = ButtonNode(size: ButtonSize.tile.cgSize)
        buttonNode.didPress.subscribe(observer: self, priority: .view) { [weak owner] _ in
            guard let owner = owner else {
                Logger.warn("tile button pressed but it's owner was deallocated, so it can't perform its action")
                return
            }

            action(owner)
        }
        buttonNode.addChild(backgroundNode)
        if let tilePreviewNode = tilePreviewNode {
            buttonNode.addChild(tilePreviewNode)
        }
        if let entityPreviewNode = entityPreviewNode {
            buttonNode.addChild(entityPreviewNode)
        }
        buttonNode.addChild(borderNode)
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

        let previewNodeAlpha = isEnabled ? 1 : Button.disabledForegroundAlpha
        tilePreviewNode?.alpha = previewNodeAlpha
        entityPreviewNode?.alpha = previewNodeAlpha
    }

    func set(scene: SJScene) {}
}
