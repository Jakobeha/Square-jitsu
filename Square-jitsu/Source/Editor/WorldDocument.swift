//
// Created by Jakob Hain on 5/21/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

/// WorldFile provides the actual file reading / writing,
/// WorldDocument adapts it into a UIDocument.
/// Note that this is only used for files which need to be edited,
/// in actual gameplay we don't need a document to load levels
class WorldDocument: UIDocument {
    private(set) var file: WorldFile? = nil

    override func read(from url: URL) throws {
        file = try WorldFile(url: url, isMutable: true)
    }

    override func contents(forType typeName: String) throws -> Any {
        if let file = file {
            return try file.encode()
        } else {
            Logger.warn("File written before loaded")
            return Data()
        }
    }
}
