//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct AdjacentSensitiveSystem: AbstractSensitiveSystem {
    static let sensitiveTypes: TileTypePred = TileTypePred([
        .adjacentSensitiveSolid,
        .dashEdge,
        .springEdge
    ])

    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func getSensitivePositions(components: Entity.Components) -> [WorldTilePos] {
        components.colC?.adjacentPositions.allElements ?? []
    }
}
