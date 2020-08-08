//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Free4TileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    static func resolve(semiAdjoiningSides: SideSet) -> SideSet {
        semiAdjoiningSides
    }

    static func getTexture(base: TextureSet, sideSet: SideSet) -> SKTexture {
        let sideSetDescription = sideSet.toBitString
        return base[sideSetDescription]
    }

    let textureBase: TextureSet

    private lazy var textures: DenseEnumMap<SideSet, SKTexture> = DenseEnumMap { sideSet in
        Free4TileViewTemplate.getTexture(base: textureBase, sideSet: sideSet)
    }

    /// - Parameters:
    ///   - base: Texture set with all textures
    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let mySides = tileType.orientation.asSideSet
        return generateNode(world: world, mySides: mySides)
    }

    private func generateNode(world: ReadonlyWorld, mySides: SideSet) -> SKSpriteNode {
        let texture = textures[mySides]
        return SKSpriteNode(texture: texture, size: world.settings.tileViewSize)
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let texture = textures[[]]
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<Free4TileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
