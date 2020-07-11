//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol TileViewTemplate {
    var fadeAction: SKAction? { get }

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode
    func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode

    func didPlaceInParent(node: SKNode)
    func didRemoveFromParent(node: SKNode)
}

extension TileViewTemplate {
    /// Adds gloss if necessary
    func generatePreviewNodeWithGloss(tileType: TileType, settings: WorldSettings, size: CGSize) -> SKNode {
        let baseNode = generatePreviewNode(size: size, settings: settings)
        if settings.glossyTileViews.contains(tileType) {
            // Add gloss effect to preview
            baseNode.zPosition = 0

            let glossNode = SKCropNode()
            let glossMask = generatePreviewNode(size: size, settings: settings)
            let glossImage = SKSpriteNode(texture: settings.glossTexture, size: size)
            glossImage.anchorPoint = UXSpriteAnchor
            glossNode.maskNode = glossMask
            glossNode.addChild(glossImage)
            glossNode.zPosition = 1

            let parentNode = SKNode()
            parentNode.addChild(baseNode)
            parentNode.addChild(glossNode)

            return parentNode
        } else {
            return baseNode
        }
    }
}