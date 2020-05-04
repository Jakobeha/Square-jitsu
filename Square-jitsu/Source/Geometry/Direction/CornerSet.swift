//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct CornerSet: OptionSet {
    static let east: CornerSet = CornerSet(rawValue: 1 << 0)
    static let northEast: CornerSet = CornerSet(rawValue: 1 << 1)
    static let north: CornerSet = CornerSet(rawValue: 1 << 2)
    static let northWest: CornerSet = CornerSet(rawValue: 1 << 3)
    static let west: CornerSet = CornerSet(rawValue: 1 << 4)
    static let southWest: CornerSet = CornerSet(rawValue: 1 << 5)
    static let south: CornerSet = CornerSet(rawValue: 1 << 6)
    static let southEast: CornerSet = CornerSet(rawValue: 1 << 7)

    let rawValue: UInt8
}
