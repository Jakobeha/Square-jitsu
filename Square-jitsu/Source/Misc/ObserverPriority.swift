//
// Created by Jakob Hain on 5/30/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum ObserverPriority: Int, Comparable {
    case model
    case input
    case view
    case presenter

    static func <(lhs: ObserverPriority, rhs: ObserverPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
