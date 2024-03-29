//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Entity: EqualityIsIdentity {
    struct Components: SingleSettingCodable {
        typealias AsSetting = StructSetting<Entity.Components>

        var locC: LocationComponent?
        var lilC: LineLocationComponent?
        var larC: LoadAroundComponent?
        var dalC: DestroyAfterLifetimeComponent?
        var codC: CreateOnDestroyComponent?
        var dynC: MovingComponent?
        var accC: AccelerationComponent?
        var ac3C: Acceleration3Component?
        var imfC: ImplicitForcesComponent?
        var colC: CollisionComponent?
        var ntlC: NearTileComponent?
        var docC: DestroyOnCollideComponent?
        var cocC: CreateOnCollideComponent?
        var dciC: DontClipComponent?
        var ricC: RicochetComponent?
        var matC: MatterComponent?
        var griC: GrabbingComponent?
        var graC: GrabbableComponent?
        var helC: HealthComponent?
        var toxC: ToxicComponent?
        var turC: TurretComponent?
        var ctrC: CollectorComponent?
        var nijC: NinjaComponent?
        var anjC: AINinjaComponent?

        static func newSetting() -> AsSetting {
            StructSetting(requiredFields: [:], optionalFields: [
                "locC": LocationComponent.newSetting(),
                "lilC": LineLocationComponent.newSetting(),
                "larC": LoadAroundComponent.newSetting(),
                "dalC": DestroyAfterLifetimeComponent.newSetting(),
                "codC": CreateOnDestroyComponent.newSetting(),
                "dynC": MovingComponent.newSetting(),
                "accC": AccelerationComponent.newSetting(),
                "ac3C": Acceleration3Component.newSetting(),
                "colC": CollisionComponent.newSetting(),
                "ntlC": NearTileComponent.newSetting(),
                "imfC": ImplicitForcesComponent.newSetting(),
                "dciC": DontClipComponent.newSetting(),
                "docC": DestroyOnCollideComponent.newSetting(),
                "cocC": CreateOnCollideComponent.newSetting(),
                "ricC": RicochetComponent.newSetting(),
                "matC": MatterComponent.newSetting(),
                "griC": GrabbingComponent.newSetting(),
                "graC": GrabbableComponent.newSetting(),
                "helC": HealthComponent.newSetting(),
                "toxC": ToxicComponent.newSetting(),
                "turC": TurretComponent.newSetting(),
                "ctrC": CollectorComponent.newSetting(),
                "nijC": NinjaComponent.newSetting(),
                "anjC": AINinjaComponent.newSetting()
            ], allowedExtraFields: []) { setting in
                let components: Components = setting.decodeDynamically()
                try components.validate()
            }
        }

        /// First item in value tuple contains dependencies (must have in order to have key),
        /// second item contains conflicts (can't have in order to have key).
        /// CNF = Conjunctive normal form ('and' of 'or's; if the key dependency is contained,
        /// at least one element from each sub-array of the value dependency must also be contained)
        private static let componentDependenciesAndConflictsCNF: [String:([[String]], [String])] = [
            "lilC": ([], ["locC"]),
            "larC": ([["locC"]], []),
            "codC": ([["locC"]], []),
            "dynC": ([["locC"]], []),
            "accC": ([["dynC"]], []),
            "ac3C": ([["dynC"]], []),
            "colC": ([["locC", "lilC"]], []),
            "ntlC": ([["locC"]], []),
            "imfC": ([["dynC"], ["locC"]], []),
            "dciC": ([["colC"], ["locC"]], []),
            "docC": ([["dynC"], ["locC"]], []),
            "cocC": ([["colC"]], []),
            "ricC": ([["dciC"], ["colC"], ["dynC"]], []),
            "matC": ([["dciC"], ["dynC"], ["locC"]], []),
            "griC": ([["colC"], ["dynC"], ["locC"]], []),
            "graC": ([["dynC"], ["locC"]], []),
            "turC": ([["dynC"], ["locC"]], []),
            "ctrC": ([["colC"]], []),
            "nijC": ([["helC"], ["ntlC"], ["colC"], ["dynC"], ["locC"]], []),
            "anjC": ([["nijC"]], [])
        ]

        func validate() throws {
            let myComponents = myComponentsAsStrings
            for (target, (dependencies, conflicts)) in Components.componentDependenciesAndConflictsCNF {
                try Components.validateComponentDependencies(myComponents: myComponents, target: target, dependenciesCNF: dependencies)
                try Components.validateComponentConflicts(myComponents: myComponents, target: target, conflicts: conflicts)
            }
        }

        private var myComponentsAsStrings: Set<String> {
            let mirror = Mirror(reflecting: self)
            let allComponents = mirror.children
            let myComponents = allComponents.filter { component in (component.value as Any?).isDefault }
            let myComponentNames = myComponents.map { component in component.label! }
            return Set(myComponentNames)
        }
        
        private static func validateComponentDependencies(myComponents: Set<String>, target: String, dependenciesCNF: [[String]]) throws {
            if myComponents.contains(target) && !dependenciesCNF.allSatisfy({ orDependencies in
                myComponents.contains(anyOf: orDependencies)
            }) {
                throw DecodeSettingError.missingComponentDependencies(target: target, dependenciesCNF: dependenciesCNF)
            }
        }

        private static func validateComponentConflicts(myComponents: Set<String>, target: String, conflicts: [String]) throws {
            if myComponents.contains(target) && myComponents.contains(anyOf: conflicts) {
                throw DecodeSettingError.hasComponentConflicts(target: target, conflicts: conflicts)
            }
        }
    }

    @discardableResult static func spawnForTile(type: TileType, world: World, pos: WorldTilePos3D) -> Entity {
        spawn(type: type, world: world, pos: pos.pos.cgPoint)
    }

    @discardableResult static func spawn(type: TileType, world: World, pos: LineSegment) -> Entity {
        spawn(type: type, world: world) { components in
            components.lilC!.position = pos
        }
    }

    @discardableResult static func spawn(type: TileType, world: World, pos: CGPoint) -> Entity {
        spawn(type: type, world: world) { components in
            components.locC!.position = pos
        }
    }

    @discardableResult static func spawn(type: TileType, world: World) -> Entity {
        spawn(type: type, world: world) { _ in }
    }

    @discardableResult static func spawn(type: TileType, world: World, configure: (inout Components) -> ()) -> Entity {
        var components = world.settings.entityData[type]!
        configure(&components)
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
