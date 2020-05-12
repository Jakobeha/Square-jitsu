//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Adjacent4TileViewTemplate: TileViewTemplate {
    static func getCoalescedForSharedTexture(sideSet: SideSet) -> SideSet {
        if sideSet.contains([.east, .west]) || sideSet.contains([.north, .south]) {
            return SideSet.all
        } else {
            return sideSet
        }
    }

    static func getTextureName(baseName: String, sideSet: SideSet) -> String {
        let sideSetDescription = sideSet.toBitString
        return "\(baseName)_\(sideSetDescription)"
    }

    private let textures: DenseEnumMap<SideSet, SKTexture>
    private let adjoiningTypes: TileTypePred

    init(baseName: String, adjoiningTypes: TileTypePred) {
        textures = DenseEnumMap { sideSet in
            let coalescedSet = Adjacent4TileViewTemplate.getCoalescedForSharedTexture(sideSet: sideSet)
            let textureName = Adjacent4TileViewTemplate.getTextureName(baseName: baseName, sideSet: coalescedSet)
            return SKTexture(imageNamed: textureName)
        }
        self.adjoiningTypes = adjoiningTypes
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        let adjacentSidesWithSameType = SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let texture = textures[adjacentSidesWithSameType]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }
}
