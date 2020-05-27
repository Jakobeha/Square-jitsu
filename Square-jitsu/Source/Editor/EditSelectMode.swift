//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum EditSelectMode {
    case rect
    case precision
    case freeHand
    case sameType

    static let defaultInstantSelect: EditSelectMode = .sameType

    var canInstantSelect: Bool {
        switch self {
        case .precision, .sameType:
            return true
        case .rect, .freeHand:
            return false
        }
    }
}
