//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EntityView: OptionalNodeView {
    private let entity: Entity

    private var settings: WorldSettings {
        entity.world!.settings
    }

    init(entity: Entity) {
        self.entity = entity
        let template = entity.world!.settings.entityViewConfigs[entity.type]
        super.init(node: template?.generateNode(entity: entity))
        if let node = node {
            node.zPosition = entity.type.entityZPosition
        }
        self.update()
    }

    func update() {
        if let node = node {
            if let locC = entity.next.locC {
                node.position = locC.position * settings.tileViewWidthHeight
                node.zRotation = CGFloat(locC.rotation.radians)
                if let spriteNode = node as? SKSpriteNode {
                    spriteNode.size = CGSize.square(sideLength: locC.radius * 2 * settings.tileViewWidthHeight)
                }
            }
            if let graC = entity.next.graC {
                if let spriteNode = node as? SKSpriteNode {
                    if let grabbedOrThrownByType = graC.grabState.grabbedOrThrownBy?.type {
                        spriteNode.colorBlendFactor = 1
                        spriteNode.color = settings.entityGrabColors[grabbedOrThrownByType]!
                    } else {
                        spriteNode.colorBlendFactor = 0
                    }
                }
            }
        }
    }

    override func removeFromParent() {
        if let fadeDuration = settings.entityViewFadeDuration[entity.type] {
            node?.zPosition += TileType.fadingZPositionOffset
            node?.run(SKAction.fadeOut(withDuration: fadeDuration)) {
                super.removeFromParent()
            }
        } else {
            super.removeFromParent()
        }
    }
}