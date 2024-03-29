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
    case inspect
    case select
    case deselect
    case move
    case copy

    var requiresSelection: Bool {
        switch self {
        case .place, .remove, .inspect, .select, .deselect:
            return false
        case .move, .copy:
            return true
        }
    }

    var affectsSelection: Bool {
        switch self {
        case .place, .remove, .inspect, .move, .copy:
            return false
        case .select, .deselect:
            return true
        }
    }
}
