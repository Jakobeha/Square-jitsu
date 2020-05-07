//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct AxisSet: OptionSet {
    static let horizontal: AxisSet = AxisSet(rawValue: 1 << 0)
    static let vertical: AxisSet = AxisSet(rawValue: 1 << 1)

    static let both: AxisSet = [AxisSet.horizontal, AxisSet.vertical]

    let rawValue: UInt8
}
