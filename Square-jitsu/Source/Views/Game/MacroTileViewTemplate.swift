//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class MacroTileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    let texture: SKTexture
    let sizeInTiles: CGSize

    init(texture: SKTexture, sizeInTiles: CGSize) {
        self.texture = texture
        self.sizeInTiles = sizeInTiles
        super.init()
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        // TODO: Show outline in editor so we know which tiles exist
        let adjoiningSides = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            world.peek(pos: adjacentPos).contains(tileType)
        })
        if adjoiningSides.isDisjoint(with: [.north, .west]) {
            let node = SKSpriteNode(texture: texture, size: sizeInTiles * world.settings.tileViewWidthHeight)
            node.anchorPoint = (CGSize.square(sideLength: 0.5) / sizeInTiles).toPoint
            return node
        } else {
            return SKNode()
        }
    }

    override func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<MacroTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "texture": TextureSetting(),
            "sizeInTiles": CGSizeRangeSetting(width: 0...CGFloat(Chunk.widthHeight), height: 0...CGFloat(Chunk.widthHeight))
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
