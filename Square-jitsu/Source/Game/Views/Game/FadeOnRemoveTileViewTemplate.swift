//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct FadeOnRemoveTileViewTemplate: TileViewTemplate, SingleSettingCodable {
    let base: TileViewTemplate
    let duration: CGFloat

    var fadeAction: SKAction? {
        SKAction.fadeOut(withDuration: TimeInterval(duration))
    }

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        base.generateNode(world: world, pos3D: pos3D, tileType: tileType)
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        base.generatePreviewNode(size: size)
    }

    func didPlaceInParent(node: SKNode) {
        base.didPlaceInParent(node: node)
    }

    func didRemoveFromParent(node: SKNode) {
        base.didRemoveFromParent(node: node)
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<FadeOnRemoveTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "base": DeferredSetting { TileViewTemplateSetting() },
            "duration": CGFloatRangeSetting(0...16)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
