//
// Created by Jakob Hain on 7/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension FileManager {
    /// Changes the URL if a file or directory already exists
    func changeUrlToAvoidConflicts(url: URL) -> URL {
        let urlParent = url.deletingLastPathComponent()
        let fileNameComponents = url.lastPathComponent.split(separator: ".")
        let baseName = fileNameComponents.first!
        let urlExtension = fileNameComponents.count > 1 ? fileNameComponents.dropFirst().joined(separator: ".") : nil

        var fixedUrl = url
        var avoidCounter = 0
        while fileExists(atPath: fixedUrl.path) {
            avoidCounter += 1

            let fixedBaseName = "\(baseName)-\(avoidCounter)"
            fixedUrl = urlParent.appendingPathComponent(fixedBaseName, isDirectory: url.hasDirectoryPath)
            if let urlExtension = urlExtension {
                fixedUrl.appendPathExtension(urlExtension)
            }
        }

        return fixedUrl
    }
}
