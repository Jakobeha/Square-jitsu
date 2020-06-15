//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// An entity with this component gets more advanced (but slow to calculate)
/// information about surrounding collisions
struct CollisionComponent: SettingCodableByCodable, Codable {
    var adjacentSides: SideSet = []
    var adjacentPositions: DenseEnumMap<Side, Set<WorldTilePos>> = [:]
    var overlappingTypes: TileTypeSet = TileTypeSet()
    /// Positions are in order they were collided
    var overlappingPositions: [WorldTilePos] = []
    /// Entities are in order they were collided
    var overlappingEntities: [Entity] = []

    /// Used to help make collisions between entities consistent
    /// relative to their indices in the world.
    /// e.g. makes them symmetric so if A collides with B, B should collide with A
    var earlyOverlappingEntities: [(fractionUntilCollision: CGFloat, entity: Entity)] = []

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

    mutating func preReset() {
        adjacentSides = []
        adjacentPositions = [:]
        overlappingTypes.removeAll()
        overlappingPositions.removeAll()
        overlappingEntities.removeAll()
    }

    mutating func postReset() {
        earlyOverlappingEntities.removeAll()
    }

    enum CodingKeys: CodingKey {}
}
