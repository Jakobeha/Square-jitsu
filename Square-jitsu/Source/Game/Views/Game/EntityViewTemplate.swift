//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol EntityViewTemplate {
    func generateNode(entity: Entity) -> SKNode
    func generatePreviewNode(size: CGSize) -> SKNode
}