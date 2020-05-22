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
        didSet { tileNode.alpha = isEnabled ? 1 : Button.disabledForegroundAlpha }
    }

    private let tileNode: SKNode
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
        tileNode = settings.tileViewTemplates[tileType]!.generatePreviewNode(size: ButtonSize.tile.cgSize)
        borderNode = SKSpriteNode(texture: nil, size: ButtonSize.tile.cgSize)
        super.init(node: ButtonNode(
            size: ButtonSize.tile.cgSize,
            action: action
        ))
        node.onTouchDown = { self.isPressed = true }
        node.onTouchUp = { self.isPressed = false }
    }
}
