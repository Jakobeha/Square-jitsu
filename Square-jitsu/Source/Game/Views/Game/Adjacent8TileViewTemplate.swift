//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Adjacent8TileViewTemplate: TileViewTemplate, SingleSettingCodable {
    typealias AsSetting = StructSetting<Adjacent8TileViewTemplate>

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
        let coalescedSet = Adjacent8TileViewTemplate.getCoalescedForSharedTexture(cornerSet: cornerSet)
        return Adjacent8TileViewTemplate.getTexture(base: textureBase, cornerSet: coalescedSet)
    }

    init(textureBase: TextureSet, adjoiningTypes: TileTypePred) {
        self.textureBase = textureBase
        self.adjoiningTypes = adjoiningTypes
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        let adjoiningCorners = CornerSet(pos.cornerAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let texture = textures[adjoiningCorners]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let texture = textures[[]]
        return SKSpriteNode(texture: texture, size: size)
    }

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "adjoiningTypes": TileTypePredSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
}
