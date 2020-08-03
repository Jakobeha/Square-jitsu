//
// Created by Jakob Hain on 7/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum TileFillerType: UInt8, CaseIterable {
    case macro
    case moving

    static let count: UInt8 = UInt8(allCases.count)
}
