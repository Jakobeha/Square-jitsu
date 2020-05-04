//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum Side: Int {
    case east
    case north
    case west
    case south

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
}
