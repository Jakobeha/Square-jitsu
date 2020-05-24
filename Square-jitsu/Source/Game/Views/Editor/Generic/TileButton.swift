//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileButton: UXNodeView<ButtonNode>, UXView {
    private static let pressedBorder: SKTexture = SKTexture(imageNamed: "UI/TileButtonPressedBorder")
    private static let selectedBorder: SKTexture = SKTexture(imageNamed: "UI/TileButtonSelectedBorder")
    private static let disabledAlpha: CGFloat = Button.disabledForegroundAlpha

    private var isPressed: Bool = false {
        didSet { borderNode.texture = borderNodeTexture }
    }
    private var isSelected: Bool {
        didSet { borderNode.texture = borderNodeTexture }
    }
    var isEnabled: Bool {
        didSet {
            let previewNodeAlpha = isEnabled ? 1 : Button.disabledForegroundAlpha
            tilePreviewNode?.alpha = previewNodeAlpha
            entityPreviewNode?.alpha = previewNodeAlpha
        }
    }

    private let backgroundNode: SKSpriteNode
    private let tilePreviewNode: SKNode?
    private let entityPreviewNode: SKNode?
    private let borderNode: SKSpriteNode

    private var borderNodeTexture: SKTexture? {
        if isPressed {
            return TileButton.pressedBorder
        } else if isSelected {
            return TileButton.selectedBorder
        } else {
            return nil
        }
    }

    var size: CGSize { ButtonSize.tile.cgSize }

    init(tileType: TileType, settings: WorldSettings, isEnabled: Bool = true, isSelected: Bool = false, action: @escaping () -> ()) {
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        backgroundNode = SKSpriteNode(texture: nil, color: SKColor.white, size: ButtonSize.tile.cgSize)
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        tilePreviewNode = settings.tileViewTemplates[tileType]?.generatePreviewNode(size: ButtonSize.tile.cgSize)
        tilePreviewNode?.zPosition = 1
        entityPreviewNode = settings.entityViewTemplates[tileType]?.generatePreviewNode(size: ButtonSize.tile.cgSize)
        entityPreviewNode?.zPosition = 2
        borderNode = SKSpriteNode(texture: nil, size: ButtonSize.tile.cgSize)
        borderNode.anchorPoint = UXSpriteAnchor
        borderNode.zPosition = 3
        super.init(node: ButtonNode(
            size: ButtonSize.tile.cgSize,
            action: action
        ))
        node.addChild(backgroundNode)
        if let tilePreviewNode = tilePreviewNode {
            node.addChild(tilePreviewNode)
        }
        if let entityPreviewNode = entityPreviewNode {
            node.addChild(entityPreviewNode)
        }
        node.addChild(borderNode)
        node.onTouchDown = { self.isPressed = true }
        node.onTouchUp = { self.isPressed = false }
    }
}
