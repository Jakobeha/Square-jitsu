//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Square4DeterminedByOrientationTileViewTemplate: TileViewTemplate, SingleSettingCodable {
    static func getCoalescedForSharedTexture(sideSet: SideSet) -> SideSet {
        sideSet
    }

    static func resolve(semiAdjoiningSides: SideSet) -> SideSet {
        semiAdjoiningSides
    }

    static func getTexture(base: TextureSet, sideSet: SideSet) -> SKTexture {
        let sideSetDescription = sideSet.toBitString
        return base[sideSetDescription]
    }

    let textureBase: TextureSet

    private lazy var textures: DenseEnumMap<SideSet, SKTexture> = DenseEnumMap { sideSet in
        let coalescedSet = Square4DeterminedByOrientationTileViewTemplate.getCoalescedForSharedTexture(sideSet: sideSet)
        return Square4DeterminedByOrientationTileViewTemplate.getTexture(base: textureBase, sideSet: coalescedSet)
    }

    /// - Parameters:
    ///   - base: Texture set with all textures
    ///   - adjoiningTypes: Will always be considered adjoining sides
    init(textureBase: TextureSet, adjoiningTypes: TileTypePred, semiAdjoiningTypes: TileTypePred) {
        self.textureBase = textureBase
    }

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        assert(world.settings.tileOrientationMeanings[tileType] == TileOrientationMeaning.atSolidBorder)
        let sides = tileType.orientation.asSideSet
        let texture = textures[sides]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let texture = textures[[]]
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    func didPlaceInParent(node: SKNode) {}

    func didRemoveFromParent(node: SKNode) {}

    // region encoding and decoding
    typealias AsSetting = StructSetting<Square4DeterminedByOrientationTileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "adjoiningTypes": TileTypePredSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
