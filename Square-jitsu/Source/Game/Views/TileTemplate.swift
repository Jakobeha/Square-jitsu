//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol TileTemplate {
    func generateNode(settings: Settings) -> SKNode
}
