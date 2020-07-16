//
// Created by Jakob Hain on 7/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum LevelPickerClipboard {
    case empty
    case cut(urls: Set<URL>)
    case copy(urls: Set<URL>)

    // region pattern matching
    var urls: Set<URL> {
        get {
            switch self {
            case .empty:
                return []
            case .cut(let urls):
                return urls
            case .copy(let urls):
                return urls
            }
        }
        set {
            switch self {
            case .empty:
                if !newValue.isEmpty {
                    fatalError("illegal state - tried to set urls in clipboard but it's empty")
                }
            case .cut(urls: _):
                self = .cut(urls: newValue)
            case .copy(urls: _):
                self = .copy(urls: newValue)
            }
        }
    }

    var itemState: LevelItemClipboardState {
        switch self {
        case .empty:
            fatalError("illegal state - stateOfItemsWhoseUrlsAreSelected called when no urls are selected")
        case .cut(urls: _):
            return .beingCut
        case .copy(urls: _):
            return .beingCopied
        }
    }
    // endregion

    var isEmpty: Bool {
        urls.isEmpty
    }

    func getStateOf(levelItem: LevelItem) -> LevelItemClipboardState {
        if let levelItemUrl = levelItem.url,
           urls.contains(levelItemUrl) {
            return itemState
        } else {
            return .none
        }
    }
}
