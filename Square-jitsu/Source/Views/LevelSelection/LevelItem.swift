//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum LevelItem {
    case newFolder
    case newLevel
    case upDirectory
    case folder(name: String, url: URL)
    case level(name: String, url: URL)

    static let loadingLabel: String = "Loading..."
    static let unknownIcon: UIImage = UIImage(named: "UI/Icons/UnknownIcon")!

    // region pattern matching
    var label: String {
        switch self {
        case .newFolder:
            return "New Folder"
        case .newLevel:
            return "New Level"
        case .upDirectory:
            return "Parent Dir"
        case .folder(let name, url: _):
            return name
        case .level(let name, url: _):
            return name
        }
    }

    var url: URL? {
        switch self {
        case .newFolder, .newLevel, .upDirectory:
            return nil
        case .folder(name: _, let url):
            return url
        case .level(name: _, let url):
            return url
        }
    }

    private var shortImageName: String {
        switch self {
        case .newFolder:
            return "NewFolder"
        case .newLevel:
            return "NewLevel"
        case .upDirectory:
            return "UpDirectory"
        case .folder(name: _, url: _):
            return "FolderIcon"
        case .level(name: _, url: _):
            return "LevelIcon"
        }
    }
    // endregion

    var icon: UIImage {
        UIImage(named: "UI/Icons/\(shortImageName)")!
    }
}
