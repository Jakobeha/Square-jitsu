//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EntityView: OptionalNodeView {
    private static func getEntityZPosition(type: TileType, settings: WorldSettings) -> CGFloat {
        settings.entityZPositions[type] ?? type.bigType.zPosition
    }

    private let entity: Entity
    private let template: EntityViewTemplate?

    // Saved so it can be used when the entity is removed
    private let settings: WorldSettings

    init(entity: Entity) {
        self.entity = entity
        self.settings = entity.world!.settings
        template = settings.entityViewTemplates[entity.type]
        super.init(node: template?.generateNode(entity: entity))
        if let node = node {
            node.zPosition = EntityView.getEntityZPosition(type: entity.type, settings: settings)
        }
        self.update()
    }

    func update() {
        if let node = node {
            if let locC = entity.next.locC {
                node.position = locC.position * settings.tileViewWidthHeight
                node.angle = locC.rotation
                if let spriteNode = node as? SKSpriteNode {
                    let scaleMode = settings.entityViewScaleModes[entity.type] ?? ScaleMode.ignoreAspect
                    spriteNode.resizeTo(size: CGSize.square(sideLength: locC.radius * 2 * settings.tileViewWidthHeight), scaleMode: scaleMode)
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
            template!.tick(entity: entity, node: node)
        }
    }

    override func removeFromParent() {
        if let fadeDuration = settings.entityViewFadeDurations[entity.type] {
            node?.zPosition += TileType.fadingZPositionOffset
            node?.run(SKAction.fadeOut(withDuration: fadeDuration)) {
                super.removeFromParent()
            }
        } else {
            super.removeFromParent()
        }
    }
}
