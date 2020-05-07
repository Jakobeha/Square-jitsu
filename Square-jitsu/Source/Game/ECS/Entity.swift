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

    static func newForSpawnTile(type: TileType, pos: WorldTilePos3D) -> Entity {
        switch type {
        case .playerSpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(),
                    docC: nil,
                    phyC: PhysicsComponent()
            ))
        case .shurikenSpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(gravity: 0),
                    docC: nil,
                    phyC: PhysicsComponent(friction: 0)
            ))
        case .enemySpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(),
                    docC: nil,
                    phyC: PhysicsComponent()
            ))
        default:
            fatalError("An entity doesn't exist for type \(type)")
        }
    }

    let type: TileType
    private(set) var prev: Components
    var next: Components

    weak var world: World? = nil
    var worldIndex: Int = -1

    private init(type: TileType, components: Components) {
        self.type = type
        prev = components
        next = components
        components.validate()
    }

    func tick() {
        prev = next
    }
}
