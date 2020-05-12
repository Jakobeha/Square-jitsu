//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Adjacent8TileViewTemplate: TileViewTemplate {
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

    static func getTextureName(baseName: String, cornerSet: CornerSet) -> String {
        let cornerSetDescription = cornerSet.toBitString
        return "\(baseName)_\(cornerSetDescription)"
    }

    private let textures: DenseEnumMap<CornerSet, SKTexture>
    private let adjoiningTypes: TileTypePred

    init(baseName: String, adjoiningTypes: TileTypePred) {
        textures = DenseEnumMap { cornerSet in
            let coalescedSet = Adjacent8TileViewTemplate.getCoalescedForSharedTexture(cornerSet: cornerSet)
            let textureName = Adjacent8TileViewTemplate.getTextureName(baseName: baseName, cornerSet: coalescedSet)
            return SKTexture(imageNamed: textureName)
        }
        self.adjoiningTypes = adjoiningTypes
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        let adjoiningCorners = CornerSet(pos.cornerAdjacents.mapValues { adjacentPos in
            adjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let texture = textures[adjoiningCorners]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }
}
