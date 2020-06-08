//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// An entity with this component which will react to tile collisions by sticking to the wall,
/// and other physics entity collisions by pushing the other entity back
struct PhysicsComponent: SettingCodableByCodable, Codable {
    var mass: CGFloat

    var adjacentSides: SideSet = []
    var adjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> = [:]
    var overlappingTypes: TileTypeSet = TileTypeSet()
    var overlappingPositions: Set<WorldTilePos> = []
    var overlappingEntities: Set<Entity> = []

    var hasAdjacents: Bool {
        adjacentSides != []
    }

    var adjacentAxes: AxisSet {
        var axes = AxisSet()
        if (adjacentSides.hasHorizontal) {
            axes.insert(.horizontal)
        }
        if (adjacentSides.hasVertical) {
            axes.insert(.vertical)
        }
        return axes
    }

    mutating func reset() {
        adjacentSides = []
        adjacentPositions = [:]
        overlappingTypes.removeAll()
        overlappingPositions.removeAll()
        overlappingEntities.removeAll()
    }

    enum CodingKeys: String, CodingKey {
        case mass
    }
}
