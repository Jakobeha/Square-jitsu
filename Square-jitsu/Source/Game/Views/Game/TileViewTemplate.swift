//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol TileViewTemplate: DynamicSettingCodable {
    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode
    func generatePreviewNode(size: CGSize) -> SKNode

    func didPlaceInParent(node: SKNode)
    func didRemoveFromParent(node: SKNode)
}