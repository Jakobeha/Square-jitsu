//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

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
}
