//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class PersonEntityViewTemplate: EmptyEntityViewTemplate, SingleSettingCodable {
    private static let noSideCanJumpTextureName: String = "InAirCanJump"
    private static let noSideCantJumpTextureName: String = "InAirCantJump"

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
        getTextureFor(side: .south, canJump: false)
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
        if entity.next.nijC == nil {
            Logger.warnSettingsAreInvalid("person entity view template must be assigned to a ninja entity (nijC)")
            return defaultTexture
        }
        // nijC also depends on colC, so the entity also detects collisions

        return getTextureFor(
            sideSet: entity.next.colC!.adjacentSides,
            canJump: NinjaSystem.canEntityJumpInAnyDirection(entity: entity)
        )
    }

    private func getTextureFor(sideSet: SideSet, canJump: Bool) -> SKTexture {
        getTextureFor(
            side: PersonEntityViewTemplate.getPreferredAdjacentSideIn(sideSet: sideSet),
            canJump: canJump
        )
    }

    private func getTextureFor(side: Side?, canJump: Bool) -> SKTexture {
        if let side = side {
            return textureBase[side.textureName]
        } else if canJump {
            return textureBase[PersonEntityViewTemplate.noSideCanJumpTextureName]
        } else {
            return textureBase[PersonEntityViewTemplate.noSideCantJumpTextureName]
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
