//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum Corner: Int, CaseIterable {
    static let numCorners: Int = 8

    case east
    case northEast
    case north
    case northWest
    case west
    case southWest
    case south
    case southEast

    var toSet: CornerSet {
        CornerSet(rawValue: 1 << UInt8(rawValue))
    }

    var isActualCorner: Bool {
        switch self {
        case .east, .north, .west, .south:
            return false
        case .northEast, .northWest, .southEast, .southWest:
            return true
        }
    }

    var offset: RelativePos {
        switch self {
        case .east:
            return RelativePos(x: 1, y: 0)
        case .northEast:
            return RelativePos(x: 1, y: 1)
        case .north:
            return RelativePos(x: 0, y: 1)
        case .northWest:
            return RelativePos(x: -1, y: 1)
        case .west:
            return RelativePos(x: -1, y: 0)
        case .southWest:
            return RelativePos(x: -1, y: -1)
        case .south:
            return RelativePos(x: 0, y: -1)
        case .southEast:
            return RelativePos(x: 1, y: -1)
        }
    }

    var directionFromCenter: Angle {
        Angle.zero + (Angle.right.toUnclamped / 2 * CGFloat(rawValue))
    }
    
    /// Returns itself if already a side,
    /// the adjacent sides if an actual corner
    var nearestSides: SideSet {
        switch self {
        case .east:
            return [.east]
        case .northEast:
            return [.north, .east]
        case .north:
            return [.north]
        case .northWest:
            return [.north, .west]
        case .west:
            return [.west]
        case .southWest:
            return [.south, .west]
        case .south:
            return [.south]
        case .southEast:
            return [.south, .east]
        }
    }

    /// If this is an actual corner, returns the nearest sides as lhs and rhs in both possible orders.
    /// Otherwise (if this is a side) returns an empty array
    var nearestSidesCartesian: [(lhs: Side, rhs: Side)] {
        switch self {
        case .east:
            return []
        case .northEast:
            return [(lhs: .north, rhs: .east), (lhs: .east, rhs: .north)]
        case .north:
            return []
        case .northWest:
            return [(lhs: .north, rhs: .west), (lhs: .west, rhs: .north)]
        case .west:
            return []
        case .southWest:
            return [(lhs: .south, rhs: .west), (lhs: .west, rhs: .south)]
        case .south:
            return []
        case .southEast:
            return [(lhs: .south, rhs: .east), (lhs: .east, rhs: .south)]
        }
    }
}
