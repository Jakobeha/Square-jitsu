//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol AbstractSensitiveSystem: System {
    static var sensitiveType: TileBigType { get }

    var prevSensitivePositions: Set<WorldTilePos> { get }
    var nextSensitivePositions: Set<WorldTilePos> { get }
}

extension AbstractSensitiveSystem {
    func tick() {
        if entity.prev.phyC != nil {
            turnOffNoLongerSensitiveTiles()
            turnOnNewSensitiveTiles()
        }
    }

    func turnOffNoLongerSensitiveTiles() {
        assert(entity.prev.phyC != nil)
        for position in noLongerSensitivePositions {
            updateTileAt(position: position, isOn: false)
        }
    }

    func turnOnNewSensitiveTiles() {
        assert(entity.prev.phyC != nil)
        for position in newSensitivePositions {
            updateTileAt(position: position, isOn: true)
        }
    }

    var noLongerSensitivePositions: Set<WorldTilePos> {
        prevSensitivePositions.subtracting(nextSensitivePositions)
    }

    var newSensitivePositions: Set<WorldTilePos> {
        nextSensitivePositions.subtracting(prevSensitivePositions)
    }

    func updateTileAt(position: WorldTilePos, isOn: Bool) {
        let tileTypes = world[position]
        for (layer, tileType) in tileTypes.enumerated() {
            if tileType.bigType == Self.sensitiveType {
                let newTileType = TileType(
                        bigType: tileType.bigType,
                        smallType: tileType.smallType.with(isOn: isOn),
                        orientation: tileType.orientation
                )
                let pos3D = WorldTilePos3D(pos: position, layer: layer)
                world[pos3D] = newTileType
            }
        }
    }
}
