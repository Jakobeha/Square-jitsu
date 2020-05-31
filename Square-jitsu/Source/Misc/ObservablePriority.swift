//
// Created by Jakob Hain on 5/30/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum ObservablePriority: Int, Comparable {
    case model
    case input
    case view

    static func <(lhs: ObservablePriority, rhs: ObservablePriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
