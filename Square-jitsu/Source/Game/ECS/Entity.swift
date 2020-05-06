//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity {
    struct Components {
        var locC: LocationComponent?
        var dynC: MovingComponent?
        var docC: DestroyOnCollideComponent?
        var phyC: PhysicsComponent?

        func validate() {
            assert(dynC == nil || (locC != nil))
            assert(docC == nil || (locC != nil && dynC != nil))
            assert(phyC == nil || (locC != nil && dynC != nil))
        }
    }

    static func newForSpawnTile(type: TileType) -> Entity {
        // TODO: Actually create entity according to tile type
        Entity(Entity.Components(locC: nil, dynC: nil, docC: nil, phyC: nil))
    }

    private(set) var prev: Components
    var next: Components

    weak var world: World? = nil
    var worldIndex: Int = -1

    init(_ components: Components) {
        prev = components
        next = components
        components.validate()
    }

    func tick() {
        prev = next
    }
}
