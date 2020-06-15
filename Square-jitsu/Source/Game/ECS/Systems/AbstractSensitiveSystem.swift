//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol AbstractSensitiveSystem: TopLevelSystem {
    static var sensitiveType: TileBigType { get }

    static func getSensitivePositions(components: Entity.Components) -> [WorldTilePos]
}

fileprivate var AllPrevSensitivePositions: Set<WorldTilePos> = Set()
fileprivate var AllNextSensitivePositions: Set<WorldTilePos> = Set()

extension AbstractSensitiveSystem {
    static func preTick(world: World) {
        AllPrevSensitivePositions = Set()
        AllNextSensitivePositions = Set()
    }

    func tick() {
        AllPrevSensitivePositions.formUnion(Self.getSensitivePositions(components: entity.prev))
        AllNextSensitivePositions.formUnion(Self.getSensitivePositions(components: entity.next))
    }

    static func postTick(world: World) {
        turnOffNoLongerSensitiveTiles(world: world)
        turnOnNewSensitiveTiles(world: world)
    }

    private static func turnOffNoLongerSensitiveTiles(world: World) {
        let noLongerSensitivePositions = AllPrevSensitivePositions.subtracting(AllNextSensitivePositions)
        for position in noLongerSensitivePositions {
            updateTileAt(world: world, position: position, isOn: false)
        }
    }

    private static func turnOnNewSensitiveTiles(world: World) {
        let newSensitivePositions = AllNextSensitivePositions.subtracting(AllPrevSensitivePositions)
        for position in newSensitivePositions {
            updateTileAt(world: world, position: position, isOn: true)
        }
    }

    private static func updateTileAt(world: World, position: WorldTilePos, isOn: Bool) {
        let tileTypes = world[position]
        for (layer, tileType) in tileTypes.enumerated() {
            if tileType.bigType == Self.sensitiveType {
                let pos3D = WorldTilePos3D(pos: position, layer: layer)
                var newTileType = tileType
                newTileType.smallType.isOn = isOn
                world.set(pos3D: pos3D, to: newTileType, persistInGame: false)
            }
        }
    }
}
