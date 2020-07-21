//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Square8TileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    static func getCoalescedForSharedTexture(cornerSet: CornerSet) -> CornerSet {
        var coalescedSet = cornerSet
        if !cornerSet.contains(.east) {
            coalescedSet.subtract([.southEast, .northEast])
        }
        if !cornerSet.contains(.north) {
            coalescedSet.subtract([.northEast, .northWest])
        }
        if !cornerSet.contains(.west) {
            coalescedSet.subtract([.northWest, .southWest])
        }
        if !cornerSet.contains(.south) {
            coalescedSet.subtract([.southWest, .southEast])
        }
        return coalescedSet
    }

    static func getTexture(base: TextureSet, cornerSet: CornerSet) -> SKTexture {
        let cornerSetDescription = cornerSet.toBitString
        return base[cornerSetDescription]
    }

    let textureBase: TextureSet
    let adjoiningTypes: TileTypePred

    private lazy var textures: DenseEnumMap<CornerSet, SKTexture> = DenseEnumMap { cornerSet in
        let coalescedSet = Square8TileViewTemplate.getCoalescedForSharedTexture(cornerSet: cornerSet)
        return Square8TileViewTemplate.getTexture(base: textureBase, cornerSet: coalescedSet)
    }

    init(textureBase: TextureSet, adjoiningTypes: TileTypePred) {
        self.textureBase = textureBase
        self.adjoiningTypes = adjoiningTypes
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let adjoiningCorners = CornerSet(pos3D.pos.cornerAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let texture = textures[adjoiningCorners]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let texture = textures[[]]
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<Square8TileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "adjoiningTypes": TileTypePredSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
