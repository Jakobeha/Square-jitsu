//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// The default implementations of all methods have no (visible) effect
class EmptyTileViewTemplate: TileViewTemplate {
    var fadeAction: SKAction? { nil }
    
    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        SKNode()
    }

    func generateGlossNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode? {
        nil
    }

    func generateEditorIndicatorNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode? {
        nil
    }

    func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        SKNode()
    }

    func generateGlossPreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode? {
        nil
    }

    func didPlaceInParent(node: SKNode) {}
    func didRemoveFromParent(node: SKNode) {}
}
