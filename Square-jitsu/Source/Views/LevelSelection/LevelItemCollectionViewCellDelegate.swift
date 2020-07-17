//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol LevelItemCollectionViewCellDelegate: AnyObject {
    func startRenaming(levelItem: LevelItem)
    func rename(cell: LevelItemCollectionViewCell, newName: String)
}
