//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum Side: Int, CaseIterable {
    case east
    case north
    case west
    case south

    var toSet: SideSet {
        SideSet(rawValue: 1 << UInt8(rawValue))
    }

    var toCorner: Corner {
        switch self {
        case .east:
            return .east
        case .north:
            return .north
        case .west:
            return .west
        case .south:
            return .south
        }
    }

    var opposite: Side {
        switch self {
        case .east:
            return .west
        case .north:
            return .south
        case .west:
            return .east
        case .south:
            return .north
        }
    }

    var rotated90DegreesClockwise: Side {
        switch self {
        case .east:
            return .south
        case .north:
            return .east
        case .west:
            return .north
        case .south:
            return .west
        }
    }

    var rotated90DegreesCounterClockwise: Side {
        switch self {
        case .east:
            return .north
        case .north:
            return .west
        case .west:
            return .south
        case .south:
            return .east
        }
    }

    var axis: Axis {
        switch self {
        case .east, .west:
            return .horizontal
        case .north, .south:
            return .vertical
        }
    }

    /// Whether this side is east (positive x) or north (positive y)
    var isPositiveOnAxis: Bool {
        switch self {
        case .east, .north:
            return true
        case .west, .south:
            return false
        }
    }

    var perpendicularOffset: RelativePos {
        switch self {
        case .east:
            return RelativePos(x: 1, y: 0)
        case .north:
            return RelativePos(x: 0, y: 1)
        case .west:
            return RelativePos(x: -1, y: 0)
        case .south:
            return RelativePos(x: 0, y: -1)
        }
    }

    var angle: Angle {
        Angle.right * CGFloat(rawValue)
    }

    func rotated90Degrees(isClockwise: Bool) -> Side {
        isClockwise ? rotated90DegreesClockwise : rotated90DegreesCounterClockwise
    }

    /// Rotated 90° counter-clockwise the given number of times (clockwise if negative)
    func rotated90Degrees(numTimes: Int) -> Side {
        var result = self
        if numTimes > 0 {
            for _ in 0..<(numTimes % Side.allCases.count) {
                result = result.rotated90DegreesCounterClockwise
            }
        } else if numTimes < 0 {
            for _ in 0..<(-numTimes % Side.allCases.count) {
                result = result.rotated90DegreesClockwise
            }
        }
        return result
    }

    func getParallelOffset(isClockwise: Bool) -> RelativePos {
        rotated90Degrees(isClockwise: isClockwise).perpendicularOffset
    }
}
