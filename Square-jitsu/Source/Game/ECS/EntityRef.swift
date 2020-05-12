//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

// A weak ref to an entity which also resolves to nil if the entity was removed from the world
struct EntityRef: Equatable, Hashable {
    private weak var entity: Entity?

    var deref: Entity? {
        if let entity = entity,
           entity.world != nil {
            return entity
        } else {
            return nil
        }
    }

    init(_ entity: Entity) {
        self.entity = entity
    }
}
