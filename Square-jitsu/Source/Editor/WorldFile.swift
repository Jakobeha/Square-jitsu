//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// API for reading and writing a world to a file. `SerialWorld` is the implementation.
/// Currently mostly a wrapper for SerialWorld but in the future it might support not having to read the entire file
class WorldFile: CustomStringConvertible {
    static let fileExtension: String = "squarejitsulevel"

    let url: URL
    private let handle: FileHandle
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
        handle = isMutable ? try FileHandle(forUpdating: url) : try FileHandle(forReadingFrom: url)
        self.isMutable = isMutable
        dispatchQueue = DispatchQueue(label: "WorldFile@\(url.lastPathComponent)")

        loadFromDisk()
    }

    func readChunkAt(pos: WorldChunkPos) -> ReadonlyChunk {
        loaded.chunks[pos] ?? Chunk()
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

    func forceCreateTile(pos: WorldTilePos, type: TileType) {
        assert(type.bigType != TileBigType.player, "can't create or move player")
        mutateChunkAt(pos: pos.worldChunkPos) { chunk in
            chunk.forcePlaceTile(pos: pos.chunkTilePos, type: type)
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
            if #available(iOS 13.0, *) {
                if let loadedData = try handle.readToEnd(),
                   !loadedData.isEmpty {
                    loaded = try SerialWorld(from: loadedData)
                }
            } else {
                let loadedData = handle.readDataToEndOfFile()
                if !loadedData.isEmpty {
                    loaded = try SerialWorld(from: loadedData)
                }
            }
        } catch {
            _didGetError.publish(WorldFileSyncError(action: "reading", error: error))
        }
    }

    func saveToDisk() {
        assert(isMutable, "mutable operation performed on immutable world file")
        do {
            let loadedData = try loaded.encode()
            dispatchQueue.async {
                do {
                    if #available(iOS 13.0, *) {
                        try self.handle.truncate(atOffset: 0)
                        try self.handle.write(contentsOf: loadedData)
                    } else {
                        self.handle.truncateFile(atOffset: 0)
                        self.handle.write(loadedData)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self._didGetError.publish(WorldFileSyncError(action: "writing", error: error))
                    }
                }
            }
        } catch {
            self._didGetError.publish(WorldFileSyncError(action: "writing", error: error))
        }
    }

    var description: String {
        "WorldFile(fileName: \(url.lastPathComponent), isMutable: \(isMutable)"
    }
}
