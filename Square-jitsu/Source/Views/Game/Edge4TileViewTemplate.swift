//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class Edge4TileViewTemplate: EmptyTileViewTemplate, SingleSettingCodable {
    static func resolve(semiAdjoiningSides: SideSet) -> SideSet {
        semiAdjoiningSides
    }

    static func getTexture(base: TextureSet, sideSet: SideSet) -> SKTexture {
        let sideSetDescription = sideSet.toBitString
        return base[sideSetDescription]
    }

    let textureBase: TextureSet

    private lazy var textures: DenseEnumMap<SideSet, SKTexture> = DenseEnumMap { sideSet in
        Edge4TileViewTemplate.getTexture(base: textureBase, sideSet: sideSet)
    }

    /// - Parameters:
    ///   - base: Texture set with all textures
    init(textureBase: TextureSet) {
        self.textureBase = textureBase
    }

    override func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        if !tileType.bigType.layer.doTilesOccupySides {
            Logger.warnSettingsAreInvalid("template should only be used on edge tiles, it was used on a tile which isn't: \(tileType)")
        }

        let mySides = tileType.orientation.asSideSet
        let textureNode = generateTextureNode(world: world, mySides: mySides)
        let maskNode = generateMaskNode(world: world, pos3D: pos3D, mySides: mySides)
        return generateNode(textureNode: textureNode, maskNode: maskNode)
    }

    private func generateTextureNode(world: ReadonlyWorld, mySides: SideSet) -> SKSpriteNode {
        let texture = textures[mySides.inverted]
        return SKSpriteNode(texture: texture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
    }
    
    private func generateMaskNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, mySides: SideSet) -> SKSpriteNode? {
        let adjoiningSides = SideSet(Corner.allCases.flatMap { corner in
            corner.nearestSidesCartesian.filter { (adjacentSide, otherAdjacentSide) in
                let adjacentPos = pos3D.pos.sideAdjacents[adjacentSide]
                let adjacentTypes = world.peek(pos: adjacentPos)
                return adjacentTypes.contains { adjacentType in
                    adjacentType.bigType.layer.doTilesOccupySides &&
                    (adjacentType.occupiedSides.contains(otherAdjacentSide.toSet) ||
                     adjacentType.occupiedSides.contains(adjacentSide.opposite.toSet))
                }
            }.map { (adjacentSide, otherAdjacentSide) in
                adjacentSide.toSet
            }
        })
        let maskedSides = adjoiningSides.inverted.subtracting(mySides)

        if let (maskTexture, numRightAngleRotations) = Edge4TileViewTemplate.getMaskTextureAndNumRightAngleRotations(settings: world.settings, maskedSides: maskedSides) {
            let maskNode = SKSpriteNode(texture: maskTexture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
            maskNode.angle = Angle(numRightAngleRotations: numRightAngleRotations)
            return maskNode
        } else {
            return nil
        }
    }

    private static func getMaskTextureAndNumRightAngleRotations(settings: WorldSettings, maskedSides: SideSet) -> (maskTexture: SKTexture, numRightAngleRotations: Int)? {
        switch maskedSides.count {
        case 0, 4:
            return nil
        default:
            let sidesMaskedByMaskTextureUnrotated = getUnrotatedEdgeMaskTextureSides(maskedSides: maskedSides)
            return (
                maskTexture: settings.edgeMaskTextureBase[getEdgeMaskTextureName(maskedSides: maskedSides)],
                numRightAngleRotations: (0..<4).first { numRotations in
                    let sidesMaskedByMaskTextureRotated90DegreesTheIndexNumberOfTimes = sidesMaskedByMaskTextureUnrotated.rotated90Degrees(numTimes: numRotations)
                    return maskedSides.contains(sidesMaskedByMaskTextureRotated90DegreesTheIndexNumberOfTimes)
                }!
            )
        }
    }

    private static func getEdgeMaskTextureName(maskedSides: SideSet) -> String {
        if maskedSides == [.north, .south] || maskedSides == [.east, .west] {
            return "101"
        } else {
            return String(repeating: "1", count: maskedSides.count)
        }
    }

    private static func getUnrotatedEdgeMaskTextureSides(maskedSides: SideSet) -> SideSet {
        if maskedSides == [.north, .south] || maskedSides == [.east, .west] {
            return [.east, .west]
        } else {
            switch maskedSides.count {
            case 1:
                return [.east]
            case 2:
                return [.east, .north]
            case 3:
                return [.east, .north, .west]
            default:
                fatalError("illegal state - getUnrotatedEdgeMaskTextureSides called with masked sides which don't get a texture")
            }
        }
    }

    private func generateNode(textureNode: SKNode, maskNode: SKNode?) -> SKNode {
        if let maskNode = maskNode {
            let node = SKCropNode()
            node.maskNode = maskNode
            node.addChild(textureNode)
            return node
        } else {
            return textureNode
        }
    }

    override func generatePreviewNodeRaw(size: CGSize, settings: WorldSettings) -> SKNode {
        let texture = textures[[]]
        let node = SKSpriteNode(texture: texture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<Edge4TileViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
