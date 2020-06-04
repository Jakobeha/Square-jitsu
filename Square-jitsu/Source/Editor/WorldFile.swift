//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// API for reading and writing a world to a file. `SerialWorld` is the implementation.
/// Currently mostly a wrapper for SerialWorld but in the future it might support not having to read the entire file
class WorldFile: ReadonlyStatelessWorld, CustomStringConvertible {
    private static let localFileDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private static let fileExtension: String = "squarejitsulevel"

    static func localUrl(baseName: String) -> URL {
        localFileDirectory.appendingPathComponent("\(baseName).\(fileExtension)")
    }

    var url: URL
    private var readHandle: FileHandle
    private let isMutable: Bool
    private let dispatchQueue: DispatchQueue
    private var loaded: SerialWorld = SerialWorld()

    private(set) var hasUnsavedChanges: Bool = false

    private let _didGetError: Publisher<Error> = Publisher()
    var didGetError: Observable<Error> { Observable(publisher: _didGetError) }

    var settingsName: String {
        get { loaded.settingsName }
        set {
            loaded.settingsName = newValue
            hasUnsavedChanges = true
        }
    }

    var backgroundName: String {
        get { loaded.backgroundName }
        set {
            loaded.backgroundName = newValue
            hasUnsavedChanges = true
        }
    }

    var settings: WorldSettings { WorldSettingsManager.all[settingsName]! }
    var backgroundLoader: WorldLoader { BackgroundWorldLoaders.all[backgroundName]! }

    init(url: URL, isMutable: Bool) throws {
        self.url = url
        if isMutable && url.path != "" && !FileManager.default.fileExists(atPath: url.path) {
            // Create a new file
            try Data().write(to: url, options: .withoutOverwriting)
        }
        readHandle = try FileHandle(forReadingFrom: url)
        self.isMutable = isMutable
        dispatchQueue = DispatchQueue(label: "WorldFile@\(url.lastPathComponent)")

        loadFromDisk()
    }

    func set(url: URL) throws {
        if self.url != url {
            // TODO: Make sure we loaded everything once we incrementally load
            self.url = url
            try resetReadHandle()
        }
    }

    func readChunkAt(pos: WorldChunkPos) -> ReadonlyChunk {
        loaded.chunks.getOrInsert(pos) {
            backgroundLoader.loadChunk(pos: pos)
        }
    }

    subscript(pos: WorldTilePos) -> [TileType] {
        let chunk = readChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    subscript(pos3D: WorldTilePos3D) -> TileType {
        get {
            let chunk = readChunkAt(pos: pos3D.pos.worldChunkPos)
            return chunk[pos3D.chunkTilePos3D]
        }
        set {
            mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
                chunk[pos3D.chunkTilePos3D] = newValue
            }
        }
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        let chunk = readChunkAt(pos: pos3D.pos.worldChunkPos)
        return chunk.getMetadataAt(pos3D: pos3D.chunkTilePos3D)
    }

    func setMetadataAt(pos3D: WorldTilePos3D, to metadata: TileMetadata?) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            if let tileBehavior = chunk.tileBehaviors[pos3D.chunkTilePos3D] {
                tileBehavior.untypedMetadata = metadata
            } else if metadata != nil {
                fatalError("can't set metadata at this position because the tile doesn't have any")
            }
        }
    }

    func forceCreateTile(pos: WorldTilePos, type: TileType) {
        assert(type.bigType != TileBigType.player, "can't create or move player")
        mutateChunkAt(pos: pos.worldChunkPos) { chunk in
            let layer = chunk.forcePlaceTile(pos: pos.chunkTilePos, type: type)

            // Notify behavior to set metadata
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            let tileBehavior = chunk.tileBehaviors[pos3D.chunkTilePos3D]
            tileBehavior?.onCreate(world: self, pos3D: pos3D)
        }
    }

    func destroyTiles(pos: WorldTilePos) {
        mutateChunkAt(pos: pos.worldChunkPos) { chunk in
            chunk.removeTiles(pos: pos.chunkTilePos)
        }
    }

    func destroyTile(pos3D: WorldTilePos3D) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            chunk[pos3D.chunkTilePos3D] = TileType.air
        }
    }

    private func mutateChunkAt(pos: WorldChunkPos, transformChunk: (Chunk) -> ()) {
        let chunk = loaded.chunks[pos] ?? Chunk()
        transformChunk(chunk)
        hasUnsavedChanges = true
    }

    private func loadFromDisk() {
        // Currently we read all the data even though it blocks
        // In the future we would read loaded chunks first,
        // then read asynchronously and only block if an unloaded chunk is requested
        do {
            try loadFromDiskSynchronously()
        } catch {
            raiseAsync(error: error)
        }
    }

    private func loadFromDiskSynchronously() throws {
        do {
            if #available(iOS 13.0, *) {
                if let loadedData = try readHandle.readToEnd(),
                   !loadedData.isEmpty {
                    loaded = try SerialWorld(from: loadedData)
                }
            } else {
                let loadedData = readHandle.readDataToEndOfFile()
                if !loadedData.isEmpty {
                    loaded = try SerialWorld(from: loadedData)
                }
            }
        } catch {
            throw WorldFileSyncError(action: "reading", error: error)
        }
    }

    func saveToDisk() {
        dispatchQueue.async {
            do {
                try self.saveToDiskSynchronously()
            } catch {
                DispatchQueue.main.async {
                    self.raiseAsync(error: error)
                }
            }
        }
    }

    func saveToDiskSynchronously() throws {
        assert(isMutable, "mutable operation performed on immutable world file")
        do {
            let loadedData = try encode()

            try closeReadHandle()
            try loadedData.write(to: url, options: [.atomic, .noFileProtection])
            try reopenReadHandle()
        } catch {
            throw WorldFileSyncError(action: "writing", error: error)
        }
    }

    /// Converts the file into data, for writing
    func encode() throws -> Data {
        try loaded.encode()
    }

    private func resetReadHandle() throws {
        try closeReadHandle()
        try reopenReadHandle()
    }

    private func closeReadHandle() throws {
        if #available(iOS 13.0, *) {
            try readHandle.close()
        } else {
            readHandle.closeFile()
        }
    }

    private func reopenReadHandle() throws {
        readHandle = try FileHandle(forReadingFrom: url)
    }

    private func raiseAsync(error: Error) {
        Logger.warn("\(self) got error: \(error)")
        _didGetError.publish(error)
    }

    var description: String {
        "WorldFile(fileName: \(url.lastPathComponent), isMutable: \(isMutable)"
    }
}
