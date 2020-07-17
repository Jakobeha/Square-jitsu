//
// Created by Jakob Hain on 7/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension URL {
    /// Drops the path components up to and including and app's sandbox directory.
    /// e.g. "/private/var/mobile/Containers/Data/Application/.../Documents" becomes "Documents"
    var localPathComponents: ArraySlice<String> {
        assert(isFileURL)
        return pathComponents.drop { pathComponent in pathComponent != "Application" }.dropFirst(2)
    }

    /// This URL and all parents except those outside the application's sandbox,
    /// in order starting with this one
    var localAncestors: [URL] {
        assert(isFileURL)
        return (0..<localPathComponents.count).map(self.deletingLastPathComponents)
    }

    /// Deletes the last `n` path components
    mutating func deleteLastPathComponents(_ n: Int) {
        for _ in 0..<n {
            deleteLastPathComponent()
        }
    }

    /// Deletes the last `n` path components
    func deletingLastPathComponents(_ n: Int) -> URL {
        var result = self
        result.deleteLastPathComponents(n)
        return result
    }

    func appending(relativePath: String) -> URL {
        var result = self

        let relativePathComponents = relativePath.split(separator: "/")
        for relativePathComponent in relativePathComponents {
            switch relativePathComponent {
            case "..":
                result.deleteLastPathComponent()
            case ".":
                break
            default:
                result.appendPathComponent(String(relativePathComponent))
            }
        }

        return result
    }
    
    func relativePathTo(url otherUrl: URL) -> String {
        assert(hasDirectoryPath, "can't get relative path from file to another url")
        
        var myDifferentPathComponents = resolvingSymlinksInPath().pathComponents
        var otherDifferentPathComponents = otherUrl.resolvingSymlinksInPath().pathComponents
        while !myDifferentPathComponents.isEmpty && !otherDifferentPathComponents.isEmpty &&
            myDifferentPathComponents.first! == otherDifferentPathComponents.first! {
            myDifferentPathComponents.removeFirst()
            otherDifferentPathComponents.removeFirst()
        }

        return (myDifferentPathComponents.isEmpty ? "./" : String(repeating: "../", count: myDifferentPathComponents.count)) + 
                otherDifferentPathComponents.joined(separator: "/")
    }
}
