//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol LevelSelectorInDirectoryDelegate: AnyObject {
    func cancelSelection()
    func selectUpDirectory()
    func select(levelFolder: LevelFolder)
    func select(level: Level)
}
