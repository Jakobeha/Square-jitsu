//
// Created by Jakob Hain on 6/26/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct CreateOnDestroySystem: OnDestroySystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    mutating func onDestroy() {
        if entity.next.codC != nil {
            let createdTileType = entity.next.codC!.createdType
            Entity.spawn(type: createdTileType, world: world, pos: entity.next.locC!.position)
        }
    }
}