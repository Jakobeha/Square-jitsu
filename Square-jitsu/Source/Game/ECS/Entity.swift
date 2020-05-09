//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity: EqualityIsIdentity {
    struct Components {
        var locC: LocationComponent? = nil
        var dynC: MovingComponent? = nil
        var imfC: ImplicitForcesComponent? = nil
        var docC: DestroyOnCollideComponent? = nil
        var phyC: PhysicsComponent? = nil
        var helC: HealthComponent? = nil
        var nijC: NinjaComponent? = nil

        func validate() {
            assert(dynC == nil || (locC != nil))
            assert(imfC == nil || (dynC != nil && locC != nil))
            assert(docC == nil || (dynC != nil && locC != nil))
            assert(phyC == nil || (dynC != nil && locC != nil))
            assert(nijC == nil || (helC != nil && phyC != nil && dynC != nil && locC != nil))
        }
    }

    static func newForSpawnTile(type: TileType, pos: WorldTilePos3D) -> Entity {
        switch type {
        case .playerSpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(),
                    imfC: ImplicitForcesComponent(),
                    phyC: PhysicsComponent(),
                    helC: HealthComponent(),
                    nijC: NinjaComponent()
            ))
        case .shurikenSpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(),
                    phyC: PhysicsComponent(solidFriction: 0)
            ))
        case .enemySpawn:
            return Entity(type: type, components: Components(
                    locC: LocationComponent(position: pos.pos.cgPoint),
                    dynC: MovingComponent(),
                    imfC: ImplicitForcesComponent(),
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
