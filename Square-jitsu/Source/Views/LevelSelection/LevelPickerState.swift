//
// Created by Jakob Hain on 7/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum LevelPickerState {
    case pick
    case edit(selectedUrls: Set<URL>, clipboard: LevelPickerClipboard)

    var isEditing: Bool {
        switch self {
        case .pick:
            return false
        case .edit(selectedUrls: _):
            return true
        }
    }

    var selectedUrls: Set<URL> {
        get {
            switch self {
            case .pick:
                return []
            case .edit(let selectedUrls, clipboard: _):
                return selectedUrls
            }
        }
        set {
            switch self {
            case .pick:
                fatalError("illegal state - level picker tried to set selected urls, but it isn't being edited")
            case .edit(selectedUrls: _, let clipboard):
                self = .edit(selectedUrls: newValue, clipboard: clipboard)
            }
        }
    }

    var clipboard: LevelPickerClipboard {
        get {
            switch self {
            case .pick:
                return .empty
            case .edit(selectedUrls: _, let clipboard):
                return clipboard
            }
        }
        set {
            switch self {
            case .pick:
                fatalError("illegal state - level picker tried to set clipboard, but it wasn't being edited")
            case .edit(let selectedUrls, clipboard: _):
                self = .edit(selectedUrls: selectedUrls, clipboard: newValue)
            }
        }
    }
}
