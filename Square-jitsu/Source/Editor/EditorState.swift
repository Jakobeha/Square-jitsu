//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum EditorState {
    case playing
    case editing

    var showEditingIndicators: Bool {
        switch self {
        case .playing:
            return false
        case .editing:
            return true
        }
    }
}
