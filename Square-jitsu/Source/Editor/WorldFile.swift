//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// API for reading and writing a world to a file. `SerialWorld` is the implementation.
/// Currently mostly a wrapper for SerialWorld but in the future it might support not having to read the entire file
class WorldFile: WritableStatelessWorld, CustomStringConvertible {
    // We need to resolve symlinks to compare urls easier,
    // because for some reason the URLs we get pseudo-randomly alternate between "/var/..." and "/private/var/..."
    static let rootDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.resolvingSymlinksInPath()
    static let fileExtension: String = "squarejitsu"

    static func localUrl(baseName: String) -> URL {
        rootDirectoryUrl.appendingPathComponent("\(baseName).\(fileExtension)")
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

    // region access
    func readChunkAt(pos: WorldChunkPos) -> ReadonlyChunk {
        loaded.chunks.getOrInsert(pos) {
            backgroundLoader.loadChunk(pos: pos)
        }
    }

    subscript(pos: WorldTilePos) -> [TileType] {
        let chunk = readChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    func _getTileTypeAt(pos3D: WorldTilePos3D) -> TileType {
        let chunk = readChunkAt(pos: pos3D.pos.worldChunkPos)
        return chunk[pos3D.chunkTilePos3D]
    }

    func getNextFreeLayerAt(pos: WorldTilePos) -> Int? {
        let chunk = readChunkAt(pos: pos.worldChunkPos)
        return chunk.getNextFreeLayerAt(pos: pos.chunkTilePos)
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        let chunk = readChunkAt(pos: pos3D.pos.worldChunkPos)
        return chunk.getMetadataAt(pos3D: pos3D.chunkTilePos3D)
    }
    // endregion

    // region mutation
    func setInternally(pos3D: WorldTilePos3D, to newType: TileType) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            chunk[pos3D.chunkTilePos3D] = newType
        }
    }

    func destroyTilesInternally(pos: WorldTilePos) {
        mutateChunkAt(pos: pos.worldChunkPos) { chunk in
            chunk.removeTiles(pos: pos.chunkTilePos)
        }
    }

    func destroyTileInternally(pos3D: WorldTilePos3D) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            chunk[pos3D.chunkTilePos3D] = TileType.air
        }
    }

    func finishCreatingTileAt(pos3D: WorldTilePos3D, type: TileType) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            // Notify behavior to set metadata
            if let tileBehavior = chunk.tileBehaviors[pos3D.chunkTilePos3D] {
                tileBehavior.onCreate(world: self, pos3D: pos3D)
            }
        }
    }

    func finishChangingTileAt(pos3D: WorldTilePos3D, type: TileType) {}

    func finishDestroyingTilesAt(pos: WorldTilePos) {}

    func setMetadataAt(pos3D: WorldTilePos3D, to metadata: TileMetadata?) {
        mutateChunkAt(pos: pos3D.pos.worldChunkPos) { chunk in
            if let tileBehavior = chunk.tileBehaviors[pos3D.chunkTilePos3D] {
                tileBehavior.untypedMetadata = metadata
            } else if metadata != nil {
                fatalError("can't set metadata at this position because the tile doesn't have any")
            }
        }
    }

    private func mutateChunkAt<T>(pos: WorldChunkPos, transformChunk: (Chunk) -> T) -> T {
        let chunk = loaded.chunks[pos] ?? Chunk()
        let result = transformChunk(chunk)
        hasUnsavedChanges = true
        return result
    }
    // endregion

    // region loading and saving
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
    // endregion

    /// Converts the file into data, for writing
    func encode() throws -> Data {
        try loaded.encode()
    }

    // region handle manipulation
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
    // endregion

    // region descriptive
    private func raiseAsync(error: Error) {
        Logger.warn("\(self) got error: \(error)")
        _didGetError.publish(error)
    }

    var description: String {
        "WorldFile(fileName: \(url.lastPathComponent), isMutable: \(isMutable)"
    }
    // endregion
}
