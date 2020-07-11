//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// The default implementations of all methods have no (visible) effect
class EmptyEntityViewTemplate: EntityViewTemplate {
    var fadeAction: SKAction? { nil }

    func generateNode(entity: Entity) -> SKNode {
        SKNode()
    }

    func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
        SKNode()
    }

    func tick(entity: Entity, node: SKNode) {}
}
