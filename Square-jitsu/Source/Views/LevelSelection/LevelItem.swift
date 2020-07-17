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

    var canBeRenamed: Bool {
        switch self {
        case .newFolder, .newLevel, .upDirectory:
            return false
        case .folder(name: _, url: _), .level(name: _, url: _):
            return true
        }
    }

    /// Returns the same item as this one except its label is renamed.
    /// Raises a fatal error if the level item can't be renamed
    func renamedTo(newName: String) -> LevelItem {
        switch self {
        case .newFolder, .newLevel, .upDirectory:
            fatalError("tried to rename level item which can't be renamed: \(self)")
        case .folder(name: _, let url):
            return .folder(
                name: newName,
                url: url
                    .deletingLastPathComponent()
                    .appendingPathComponent(newName, isDirectory: true)
            )
        case .level(name: _, let url):
            return .level(
                name: newName,
                url: url
                    .deletingLastPathComponent()
                    .appendingPathComponent(newName, isDirectory: false)
                    .appendingPathExtension(url.pathExtension)
            )
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
