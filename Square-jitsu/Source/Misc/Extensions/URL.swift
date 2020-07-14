//
// Created by Jakob Hain on 7/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension URL {
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
        assert(!isFileURL, "can't get relative path from file to another url")
        
        var myDifferentPathComponents = pathComponents
        var otherDifferentPathComponents = otherUrl.pathComponents
        while !myDifferentPathComponents.isEmpty && !otherDifferentPathComponents.isEmpty &&
            myDifferentPathComponents.first! == otherDifferentPathComponents.first! {
                myDifferentPathComponents.removeFirst()
                otherDifferentPathComponents.removeFirst()
        }
        
        if myDifferentPathComponents.isEmpty && otherDifferentPathComponents.isEmpty {
            return "./"
        } else {
            return String(repeating: "../", count: myDifferentPathComponents.count) + otherDifferentPathComponents.joined(separator: "/")
        }
    }
}
