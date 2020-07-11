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
}
