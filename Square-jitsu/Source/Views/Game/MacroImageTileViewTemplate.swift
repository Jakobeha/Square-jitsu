//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroImageTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        // TODO: Show outline in editor so we know which tiles exist
        guard let imageMetadata = world.getMetadataAt(pos3D: pos3D) as? ImageMetadata else {
            Logger.warnSettingsAreInvalid("image tile view template applied on tile without image metadata")
            return SKNode()
        }

        let texture = imageMetadata.imageTexture.texture
        let sizeInTiles = imageMetadata.sizeInTiles

        let adjoiningSides = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            world.peek(pos: adjacentPos).contains(tileType)
        })
        if adjoiningSides.isDisjoint(with: [.south, .west]) {
            let node = SKSpriteNode(texture: texture, size: world.settings.tileViewSize * sizeInTiles)
            node.anchorPoint = (CGSize.square(sideLength: 0.5) / sizeInTiles).toPoint
            return node
        } else {
            return SKNode()
        }
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: settings.imagePlaceholderTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<MacroImageTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [:], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
