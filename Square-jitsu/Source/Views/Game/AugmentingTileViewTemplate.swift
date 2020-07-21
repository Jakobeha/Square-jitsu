//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Calls to `super` will call the method on `base`
class AugmentingTileViewTemplate: TileViewTemplate {
    // We need to add DynamicSettingCodable as a hack,
    // so that the sourcery-generated code compiles
    let base: (TileViewTemplate & DynamicSettingCodable)?

    var fadeAction: SKAction? { base?.fadeAction }

    init(base: TileViewTemplate?) {
        self.base = base as! (TileViewTemplate & DynamicSettingCodable)?
    }

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        base?.generateNode(world: world, pos3D: pos3D, tileType: tileType) ?? SKNode()
    }

    func generateEditorIndicatorNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode? {
        base?.generateEditorIndicatorNode(world: world, pos3D: pos3D, tileType: tileType)
    }

    func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        base?.generatePreviewNodeRaw(size: size, settings: settings) ?? SKNode()
    }

    func didPlaceInParent(node: SKNode) {
        base?.didPlaceInParent(node: node)
    }

    func didRemoveFromParent(node: SKNode) {
        base?.didRemoveFromParent(node: node)
    }
}
