//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class PersonEntityViewTemplate: EmptyEntityViewTemplate, SingleSettingCodable {
    private static let sideTextureNames: DenseEnumMap<Side, String> = DenseEnumMap(dictionaryLiteral:
        (.east, "East"),
        (.north, "North"),
        (.west, "West"),
        (.south, "South")
    )
    private static let noSideTextureName: String = "InAir"

    private static func getPreferredAdjacentSideIn(sideSet: SideSet) -> Side? {
        if sideSet.contains(.south) {
            return .south
        } else if sideSet.contains(.north) {
            return .north
        } else if sideSet.contains(.west) {
            return .west
        } else if sideSet.contains(.east) {
            return .east
        } else {
            return nil
        }
    }

    let textureBase: TextureSet

    private var defaultTexture: SKTexture {
        getTextureFor(side: .south)
    }

    init(textureBase: TextureSet) {
        self.textureBase = textureBase
        super.init()
    }

    override func generateNode(entity: Entity) -> SKNode {
        SKSpriteNode(texture: getTextureFor(entity: entity))
    }

    override func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
        let node = SKSpriteNode(texture: defaultTexture, size: size)
        node.anchorPoint = UXSpriteAnchor
        return node
    }

    override func tick(entity: Entity, node: SKNode) {
        let spriteNode = node as! SKSpriteNode
        spriteNode.texture = getTextureFor(entity: entity)
    }

    private func getTextureFor(entity: Entity) -> SKTexture {
        if entity.next.colC == nil {
            Logger.warnSettingsAreInvalid("person entity view template must be assigned to an entity which detects collisions")
            return defaultTexture
        }

        return getTextureFor(sideSet: entity.next.colC!.adjacentSides)
    }

    private func getTextureFor(sideSet: SideSet) -> SKTexture {
        getTextureFor(side: PersonEntityViewTemplate.getPreferredAdjacentSideIn(sideSet: sideSet))
    }

    private func getTextureFor(side: Side?) -> SKTexture {
        if let side = side {
            return textureBase[PersonEntityViewTemplate.sideTextureNames[side]]
        } else {
            return textureBase[PersonEntityViewTemplate.noSideTextureName]
        }
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<PersonEntityViewTemplate>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "textureBase": TextureSetSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}
