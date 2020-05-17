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

    var axis: Axis {
        switch self {
        case .east, .west:
            return .horizontal
        case .north, .south:
            return .vertical
        }
    }

    var offset: RelativePos {
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
}
