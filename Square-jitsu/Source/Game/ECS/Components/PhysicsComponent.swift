//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// An entity with this component which will react to tile collisions by sticking to the wall,
/// and other physics entity collisions by pushing the other entity back
struct PhysicsComponent {
    var mass: CGFloat = 1
    var friction: CGFloat = 0.25

    var adjacentSides: SideSet = []
    var adjacentPositions: [WorldTilePos] = []
    var overlappingEntities: [Entity] = []

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
        adjacentPositions = []
        overlappingEntities = []
    }
}
