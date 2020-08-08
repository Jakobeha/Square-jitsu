//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Diamond4TileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    static func getCoalescedForSharedTexture(sideSet: SideSet) -> SideSet {
        if sideSet.contains([.east, .west]) || sideSet.contains([.north, .south]) {
            return SideSet.all
        } else {
            return sideSet
        }
    }

    static func resolve(semiAdjoiningSides: SideSet, preferClockwise: Bool) -> SideSet {
        if semiAdjoiningSides == [.south, .east, .north] {
            return preferClockwise ? [.south, .east] : [.east, .north]
        } else if semiAdjoiningSides == [.east, .north, .west] {
            return preferClockwise ? [.east, .north] : [.north, .west]
        } else if semiAdjoiningSides == [.north, .west, .south] {
            return preferClockwise ? [.south, .west] : [.west, .south]
        } else if semiAdjoiningSides == [.west, .south, .east] {
            return preferClockwise ? [.west, .south] : [.south, .east]
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
    let semiAdjoiningTypes1: TileTypePred
    let semiAdjoiningTypes2: TileTypePred

    private lazy var textures: DenseEnumMap<SideSet, SKTexture> = DenseEnumMap { sideSet in
        let coalescedSet = Diamond4TileViewTemplate.getCoalescedForSharedTexture(sideSet: sideSet)
        return Diamond4TileViewTemplate.getTexture(base: textureBase, sideSet: coalescedSet)
    }

    /// - Parameters:
    ///   - base: Texture set with all textures
    ///   - adjoiningTypes: Will always be considered adjoining sides
    ///   - semiAdjoiningTypes1: Will not adjoin in certain combinations - specifically, 3 consecutive semi-adjoining sides will be treated as only the 2 most counter-clockwise ones
    ///   - semiAdjoiningTypes1: Will not adjoin in certain combinations - specifically, 3 consecutive semi-adjoining sides will be treated as only the 2 most clockwise ones
    init(textureBase: TextureSet, adjoiningTypes: TileTypePred, semiAdjoiningTypes1: TileTypePred, semiAdjoiningTypes2: TileTypePred) {
        self.textureBase = textureBase
        self.adjoiningTypes = adjoiningTypes
        self.semiAdjoiningTypes1 = semiAdjoiningTypes1
        self.semiAdjoiningTypes2 = semiAdjoiningTypes2
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        let alwaysAdjoiningSides = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let semiAdjoiningSides1 = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            semiAdjoiningTypes1.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let semiAdjoiningSides2 = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
            semiAdjoiningTypes2.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let adjoiningSides = alwaysAdjoiningSides
            .union(Diamond4TileViewTemplate.resolve(semiAdjoiningSides: semiAdjoiningSides1, preferClockwise: false))
            .union(Diamond4TileViewTemplate.resolve(semiAdjoiningSides: semiAdjoiningSides2, preferClockwise: true))
        let texture = textures[adjoiningSides]
        return SKSpriteNode(texture: texture, size: world.settings.tileViewSize)
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let texture = textures[[]]
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<Diamond4TileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting(),
            "adjoiningTypes": TileTypePredSetting(),
            "semiAdjoiningTypes1": TileTypePredSetting(),
            "semiAdjoiningTypes2": TileTypePredSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
