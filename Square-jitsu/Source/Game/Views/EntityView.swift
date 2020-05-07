//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EntityView: OptionalNodeView {
    private let entity: Entity

    init(entity: Entity) {
        self.entity = entity
        let template = entity.world!.settings.entityViewConfigs[entity.type]
        super.init(node: template?.generateNode(entity: entity))
        if let node = node {
            node.zPosition = entity.type.bigType.layer.zPosition
        }
        self.update()
    }

    func update() {
        if let node = node {
            if let locC = entity.next.locC {
                node.position = locC.position * entity.world!.settings.tileViewWidthHeight
                node.zRotation = CGFloat(locC.rotation.radians)
                if let spriteNode = node as? SKSpriteNode {
                    spriteNode.size = CGSize.square(sideLength: locC.radius * 2 * entity.world!.settings.tileViewWidthHeight)
                }
            }
        }
    }
}
