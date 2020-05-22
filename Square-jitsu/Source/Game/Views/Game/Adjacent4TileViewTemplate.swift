//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Adjacent4TileViewTemplate: TileViewTemplate, SingleSettingCodable {
    typealias AsSetting = StructSetting<Adjacent4TileViewTemplate>

    static func getCoalescedForSharedTexture(sideSet: SideSet) -> SideSet {
        if sideSet.contains([.east, .west]) || sideSet.contains([.north, .south]) {
            return SideSet.all
        } else {
            return sideSet
        }
    }

    static func resolve(semiAdjoiningSides: SideSet) -> SideSet {
        if semiAdjoiningSides == [.south, .east, .north] {
            return [.east, .north]
        } else if semiAdjoiningSides == [.east, .north, .west] {
            return [.north, .west]
        } else if semiAdjoiningSides == [.north, .west, .south] {
            return [.west, .south]
        } else if semiAdjoiningSides == [.west, .south, .east] {
            return [.south, .east]
        } else {
            return semiAdjoiningSides
        }
    }

    static func getTexture(base: TextureSet, sideSet: SideSet) -> SKTexture {
        let sideSetDescription = sideSet.toBitString
        return base[sideSetDescription]
    }

    let textureBase: TextureSet
    let adjoiningTypes: TileTypePred
    let semiAdjoiningTypes: TileTypePred
    
    private lazy var textures: DenseEnumMap<SideSet, SKTexture> = DenseEnumMap { sideSet in
        let coalescedSet = Adjacent4TileViewTemplate.getCoalescedForSharedTexture(sideSet: sideSet)
        return Adjacent4TileViewTemplate.getTexture(base: textureBase, sideSet: coalescedSet)
    }

    /// - Parameters:
    ///   - base: Texture set with all textures
    ///   - adjoiningTypes: Will always be considered adjoining sides
    ///   - semiAdjoiningTypes: Will not adjoin in certain combinations - specifically, 3 consecutive semi-adjoining sides will be treated as 2 only adjoining sides
    init(textureBase: TextureSet, adjoiningTypes: TileTypePred, semiAdjoiningTypes: TileTypePred) {
        self.textureBase = textureBase
        self.adjoiningTypes = adjoiningTypes
        self.semiAdjoiningTypes = semiAdjoiningTypes
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        let alwaysAdjoiningSides = SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let semiAdjoiningSides = SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            semiAdjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let adjoiningSides = alwaysAdjoiningSides.union(Adjacent4TileViewTemplate.resolve(semiAdjoiningSides: semiAdjoiningSides))
        let texture = textures[adjoiningSides]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let texture = textures[[]]
        return SKSpriteNode(texture: texture, size: size)
    }

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "adjoiningTypes": TileTypePredSetting(),
            "semiAdjoiningTypes": TileTypePredSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
}
