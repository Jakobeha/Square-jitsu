//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol LevelPickerInDirectoryDelegate: AnyObject {
    func cancelPick()
    func moveUpDirectory()
    func moveInto(levelFolder: LevelFolder)
    func pick(level: Level)
    func startEditing()
    func select(url: URL)
    func deselect(url: URL)
    func pasteIn(directoryUrl: URL)
    func completeEditing()
}
