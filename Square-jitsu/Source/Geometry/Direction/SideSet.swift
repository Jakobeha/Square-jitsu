//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct SideSet: OptionSet {
    static let east: CornerSet = CornerSet(rawValue: 1 << 0)
    static let north: CornerSet = CornerSet(rawValue: 1 << 1)
    static let west: CornerSet = CornerSet(rawValue: 1 << 2)
    static let south: CornerSet = CornerSet(rawValue: 1 << 3)

    let rawValue: UInt8

    var toSet: SideSet {
        SideSet(rawValue: 1 << UInt8(rawValue))
    }
}
