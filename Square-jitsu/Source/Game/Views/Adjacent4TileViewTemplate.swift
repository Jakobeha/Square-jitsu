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

    static func getTextureName(baseName: String, sideSet: SideSet) -> String {
        let sideSetDescription = sideSet.toBitString
        return "\(baseName)_\(sideSetDescription)"
    }

    private let textures: DenseEnumMap<SideSet, SKTexture>
    private let alwaysAdjoiningTypes: TileTypePred
    private let semiAdjoiningTypes: TileTypePred

    /// - Parameters:
    ///   - baseName: Base texture name
    ///   - adjoiningTypes: Will always be considered adjoining sides
    ///   - semiAdjoiningTypes: Will not adjoin in certain combinations - specifically, 3 consecutive semi-adjoining sides will be treated as 2 only adjoining sides
    init(baseName: String, adjoiningTypes: TileTypePred, semiAdjoiningTypes: TileTypePred) {
        textures = DenseEnumMap { sideSet in
            let coalescedSet = Adjacent4TileViewTemplate.getCoalescedForSharedTexture(sideSet: sideSet)
            let textureName = Adjacent4TileViewTemplate.getTextureName(baseName: baseName, sideSet: coalescedSet)
            return SKTexture(imageNamed: textureName)
        }
        self.alwaysAdjoiningTypes = adjoiningTypes
        self.semiAdjoiningTypes = semiAdjoiningTypes
    }

    func generateNode(world: World, pos: WorldTilePos, tileType: TileType) -> SKNode {
        let alwaysAdjoiningSides = SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            alwaysAdjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let semiAdjoiningSides = SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            semiAdjoiningTypes.contains(anyOf: world.peek(pos: adjacentPos))
        })
        let adjoiningSides = alwaysAdjoiningSides.union(Adjacent4TileViewTemplate.resolve(semiAdjoiningSides: semiAdjoiningSides))
        let texture = textures[adjoiningSides]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }
}
