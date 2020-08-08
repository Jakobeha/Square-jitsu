//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum EditSelectMode: Equatable {
    case rect
    case precision(backIndex: Int)
    case freeHand
    case sameType(backIndex: Int)

    static let defaultInstantSelect: EditSelectMode = .sameType(backIndex: 0)

    static func getBackIndexAfter(_ backIndex: Int?) -> Int {
        if let backIndex = backIndex {
            return (backIndex + 1) % Chunk.numLayers
        } else {
            return 0
        }
    }

    var isPrecision: Bool {
        switch self {
        case .precision(backIndex: _):
            return true
        default:
            return false
        }
    }

    var isSameType: Bool {
        switch self {
        case .sameType(backIndex: _):
            return true
        default:
            return false
        }
    }

    var canInstantSelect: Bool {
        switch self {
        case .precision(backIndex: _), .sameType(backIndex: _):
            return true
        case .rect, .freeHand:
            return false
        }
    }

    var backIndex: Int? {
        switch self {
        case .precision(let backIndex):
            return backIndex
        case .sameType(let backIndex):
            return backIndex
        default:
            return nil
        }
    }
}
