//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol AbstractSensitiveSystem: TopLevelSystem {
    static var sensitiveTypes: TileTypePred { get }

    static func getSensitivePositions(components: Entity.Components) -> [WorldTilePos]
}

fileprivate var AllPrevSensitivePositions: [ObjectIdentifier:Set<WorldTilePos>] = [:]
fileprivate var AllNextSensitivePositions: [ObjectIdentifier:Set<WorldTilePos>] = [:]

extension AbstractSensitiveSystem {
    private static var allPrevSensitivePositions: Set<WorldTilePos> {
        get { AllPrevSensitivePositions[ObjectIdentifier(Self.self)] ?? [] }
        set { AllPrevSensitivePositions[ObjectIdentifier(Self.self)] = newValue }
    }

    private static var allNextSensitivePositions: Set<WorldTilePos> {
        get { AllNextSensitivePositions[ObjectIdentifier(Self.self)] ?? [] }
        set { AllNextSensitivePositions[ObjectIdentifier(Self.self)] = newValue }
    }
    
    static func preTick(world: World) {
        allPrevSensitivePositions = allNextSensitivePositions
        allNextSensitivePositions = []
    }

    func tick() {
        Self.allNextSensitivePositions.formUnion(Self.getSensitivePositions(components: entity.next))
    }

    static func postTick(world: World) {
        turnOffNoLongerSensitiveTiles(world: world)
        turnOnNewSensitiveTiles(world: world)
    }

    private static func turnOffNoLongerSensitiveTiles(world: World) {
        let noLongerSensitivePositions = allPrevSensitivePositions.subtracting(allNextSensitivePositions)
        for position in noLongerSensitivePositions {
            updateTileAt(world: world, position: position, isOn: false)
        }
    }

    private static func turnOnNewSensitiveTiles(world: World) {
        let newSensitivePositions = allNextSensitivePositions.subtracting(allPrevSensitivePositions)
        for position in newSensitivePositions {
            updateTileAt(world: world, position: position, isOn: true)
        }
    }

    private static func updateTileAt(world: World, position: WorldTilePos, isOn: Bool) {
        let tileTypes = world[position]
        for (layer, tileType) in tileTypes.enumerated() {
            if Self.sensitiveTypes.contains(tileType) {
                let pos3D = WorldTilePos3D(pos: position, layer: layer)
                var newTileType = tileType
                newTileType.smallType.isOn = isOn
                world[pos3D] = newTileType
            }
        }
    }
}
