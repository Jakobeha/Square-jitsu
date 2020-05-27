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
    private var _file: WorldFile? = nil

    override func read(from url: URL) throws {
        _file = try WorldFile(url: url, isMutable: true)
    }

    override func writeContents(_ contents: Any, to url: URL, for saveOperation: SaveOperation, originalContentsURL: URL?) throws {
        if _file == nil {
            Logger.warn("File written before loaded")
            _file = try WorldFile(url: url, isMutable: true)
        } else {
            try _file!.set(url: url)
        }
        try _file!.saveToDiskSynchronously()
    }

    func getFile() throws -> WorldFile {
        if _file == nil {
            _file = try WorldFile(url: fileURL, isMutable: true)
        }
        return _file!
    }
}
