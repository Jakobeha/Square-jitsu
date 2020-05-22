//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Whether tiles are placed, removed, etc.
/// What happens to selected tiles or regions)
enum EditActionMode {
    case place
    case remove
    case select
    case move
    case inspect

    var requiresSelection: Bool {
        switch self {
        case .place, .remove:
            return false
        case .select, .move, .inspect:
            return true
        }
    }
}
