//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol LevelPickerInDirectoryDelegate: AnyObject {
    func cancelPick(animated: Bool)
    func moveUpDirectory(animated: Bool)
    func moveInto(levelFolder: LevelFolder, animated: Bool)
    func pick(level: Level, animated: Bool)
    func startEditing()
    func select(url: URL)
    func deselect(url: URL)
    func delete(url: URL)
    func pasteIn(directoryUrl: URL)
    func completeEditing()
}
