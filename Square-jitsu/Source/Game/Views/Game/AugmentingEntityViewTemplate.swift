//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Calls to `super` will call the method on `base`
class AugmentingEntityViewTemplate: EntityViewTemplate {
    // We need to add DynamicSettingCodable as a hack,
    // so that the sourcery-generated code compiles
    let base: EntityViewTemplate & DynamicSettingCodable

    var fadeAction: SKAction? { base.fadeAction }

    init(base: EntityViewTemplate) {
        self.base = base as! EntityViewTemplate & DynamicSettingCodable
    }

    func generateNode(entity: Entity) -> SKNode {
        base.generateNode(entity: entity)
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        base.generatePreviewNode(size: size)
    }

    func tick(entity: Entity, node: SKNode) {
        base.tick(entity: entity, node: node)
    }
}
