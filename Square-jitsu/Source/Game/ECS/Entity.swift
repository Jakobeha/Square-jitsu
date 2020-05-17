//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity: EqualityIsIdentity {
    struct Components: SingleSettingCodable {
        typealias AsSetting = StructSetting<Entity.Components>

        var locC: LocationComponent?
        var larC: LoadAroundComponent?
        var dynC: MovingComponent?
        var imfC: ImplicitForcesComponent?
        var docC: DestroyOnCollideComponent?
        var phyC: PhysicsComponent?
        var ntlC: NearTileComponent?
        var griC: GrabbingComponent?
        var graC: GrabbableComponent?
        var helC: HealthComponent?
        var toxC: ToxicComponent?
        var turC: TurretComponent?
        var nijC: NinjaComponent?

        static func newSetting() -> AsSetting {
            StructSetting(requiredFields: [:], optionalFields: [
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
                "toxC": ToxicComponent.newSetting(),
                "turC": TurretComponent.newSetting(),
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
            "turC": ["dynC", "locC"],
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

    @discardableResult static func newForSpawnTile(type: TileType, pos: WorldTilePos3D, world: World) -> Entity {
        new(type: type, pos: pos.pos.cgPoint, world: world)
    }

    @discardableResult static func new(type: TileType, pos: CGPoint?, world: World) -> Entity {
        var components = world.settings.entityData[type]!
        if let pos = pos {
            components.locC?.position = pos
        }
        let entity = Entity(type: type, components: components)
        world.add(entity: entity)
        return entity
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
