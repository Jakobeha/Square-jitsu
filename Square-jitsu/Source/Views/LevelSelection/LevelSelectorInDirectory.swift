//
// Created by Jakob Hain on 7/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class LevelSelectorInDirectory {
    static func listFromRootUntil(url: URL) throws -> [LevelSelectorInDirectory] {
        var elements: [LevelSelectorInDirectory] = []
        var currentUrl = url
        while !(elements.last?.isRoot ?? false) {
            elements.append(try LevelSelectorInDirectory(url: currentUrl))
            currentUrl.deleteLastPathComponent()
        }
        elements.reverse()
        return elements
    }

    let url: URL

    private(set) var levels: [Level]!
    private(set) var folders: [LevelFolder]!
    private(set) var isRoot: Bool!

    private(set) var levelItems: [LevelItem]!

    init(url: URL) throws {
        self.url = url

        try reload()
    }

    func reload() throws {
        let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey])
        levels = files.filter { fileUrl in
            !fileUrl.hasDirectoryPath && fileUrl.pathExtension == WorldFile.fileExtension
        }.map(Level.init).sorted { $0.name < $1.name }
        folders = files.filter { fileUrl in
            fileUrl.hasDirectoryPath
        }.map(LevelFolder.init).sorted { $0.name < $1.name }
        isRoot = url == WorldFile.rootDirectoryUrl

        levelItems = [
            .newFolder,
            .newLevel
        ] + (isRoot ? [] : [.upDirectory]) + folders.map { folder in
            folder.toLevelItem
        } + levels.map { level in
            level.toLevelItem
        }
    }

    func getSubLevelFolderWith(name: String) -> URL {
        url.appendingPathComponent(name, isDirectory: true)
    }

    func getSubLevelWith(name: String) -> URL {
        url.appendingPathComponent(name, isDirectory: false).appendingPathExtension(WorldFile.fileExtension)
    }

    func getIndexOfNewLevelFolderWith(name: String) -> Int {
        2 + (isRoot ? 0 : 1) + (folders.firstIndex { levelFolder in
            levelFolder.name > name
        } ?? folders.count)
    }

    func getIndexOfNewLevelWith(name: String) -> Int {
        2 + (isRoot ? 0 : 1) + folders.count + (levels.firstIndex { level in
            level.name > name
        } ?? levels.count)
    }
}
