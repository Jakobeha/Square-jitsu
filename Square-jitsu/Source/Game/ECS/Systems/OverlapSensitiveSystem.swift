//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct OverlapSensitiveSystem: AbstractSensitiveSystem {
    static let sensitiveType: TileBigType = TileBigType.overlapSensitiveBackground

    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    var prevSensitivePositions: Set<WorldTilePos> {
        entity.prev.phyC!.overlappingPositions
    }

    var nextSensitivePositions: Set<WorldTilePos> {
        entity.next.phyC!.overlappingPositions
    }
}
