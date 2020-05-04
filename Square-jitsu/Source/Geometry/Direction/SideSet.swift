//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct SideSet: OptionSet {
    static let east: SideSet = SideSet(rawValue: 1 << 0)
    static let north: SideSet = SideSet(rawValue: 1 << 1)
    static let west: SideSet = SideSet(rawValue: 1 << 2)
    static let south: SideSet = SideSet(rawValue: 1 << 3)

    let rawValue: UInt8

    var hasHorizontal: Bool {
        contains(SideSet.east) || contains(SideSet.west)
    }

    var hasVertical: Bool {
        contains(SideSet.north) || contains(SideSet.south)
    }
}
