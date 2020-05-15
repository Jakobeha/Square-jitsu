//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity: EqualityIsIdentity {
    struct Components: SingleSettingCodable {
        typealias AsSetting = StructSetting<Entity.Components>

        var locC: LocationComponent? = nil
        var larC: LoadAroundComponent? = nil
        var dynC: MovingComponent? = nil
        var imfC: ImplicitForcesComponent? = nil
        var docC: DestroyOnCollideComponent? = nil
        var phyC: PhysicsComponent? = nil
        var ntlC: NearTileComponent? = nil
        var griC: GrabbingComponent? = nil
        var graC: GrabbableComponent? = nil
        var helC: HealthComponent? = nil
        var toxC: ToxicComponent? = nil
        var nijC: NinjaComponent? = nil

        static func newSetting() -> AsSetting {
            StructSetting([
                "locC": CodableStructSetting<LocationComponent>(),
                "larC": CodableStructSetting<LoadAroundComponent>(),
                "dynC": CodableStructSetting<MovingComponent>(),
                "imfC": CodableStructSetting<ImplicitForcesComponent>(),
                "docC": CodableStructSetting<DestroyOnCollideComponent>(),
                "phyC": CodableStructSetting<PhysicsComponent>(),
                "ntlC": CodableStructSetting<NearTileComponent>(),
                "griC": CodableStructSetting<GrabbingComponent>(),
                "graC": CodableStructSetting<GrabbableComponent>(),
                "helC": CodableStructSetting<HealthComponent>(),
                "toxC": CodableStructSetting<ToxicComponent>(),
                "nijC": CodableStructSetting<NinjaComponent>()
            ], allowedExtraFields: []) { setting in
                let components: Components = setting.decodeDynamically()
                try components.validate()
            }
        }

        private static let componentDependencies: [String:[String]] = [
            "larC": ["locC"],
            "dynC": ["locC"],
            "imfC": ["dynC", "locC"],
            "docC": ["dynC", "locC"],
            "phyC": ["dynC", "locC"],
            "ntlC": ["phyC", "dynC", "locC"],
            "griC": ["phyC", "dynC", "locC"],
            "graC": ["dynC", "locC"],
            "nijC": ["helC", "ntlC", "phyC", "dynC", "locC"]
        ]

        func validate() throws {
            let myComponents = myComponentsAsStrings
            for (target, dependencies) in Components.componentDependencies {
                try Components.validateDependenciesOfComponent(myComponents: myComponents, target: target, dependencies: dependencies)
            }
        }

        private var myComponentsAsStrings: Set<String> {
            let mirror = Mirror(reflecting: self)
            let allComponents = mirror.children
            let myComponents = allComponents.filter { component in (component.value as Any?) != nil }
            let myComponentNames = myComponents.map { component in component.label! }
            return Set(myComponentNames)
        }
        
        private static func validateDependenciesOfComponent(myComponents: Set<String>, target: String, dependencies: [String]) throws {
            if myComponents.contains(target) && !myComponents.contains(allOf: dependencies) {
                throw DecodeSettingError.missingComponentDependencies(target: target, dependencies: dependencies)
            }
        }
    }

    static func newForSpawnTile(type: TileType, pos: WorldTilePos3D, world: World) -> Entity {
        var components = world.settings.entityData[type]!
        components.locC?.position = pos.pos.cgPoint
        return Entity(type: type, components: components)
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
    }

    func tick() {
        prev = next
    }
}
