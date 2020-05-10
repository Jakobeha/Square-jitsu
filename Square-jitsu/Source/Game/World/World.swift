//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class World {
    private let loader: WorldLoader
    let settings: WorldSettings
    private var chunks: [WorldChunkPos : Chunk] = [:]
    var readonlyChunks: [WorldChunkPos : ReadonlyChunk] {
        chunks.mapValues { $0 as ReadonlyChunk }
    }
    private var chunkPositionsLoadedBefore: Set<WorldChunkPos> = Set()

    private(set) var entities: [Entity] = []

    var speed: CGFloat = 1 {
        didSet {
            _didChangeSpeed.publish()
        }
    }

    private var _player: Entity? = nil
    var player: Entity {
        get {
            assert(_player != nil, "world isn't loaded yet, the player spawn chunk must be loaded, which loads the player spawn and sets the player entity")
            return _player!
        }
        set {
            assert(_player == nil, "player already loaded, one player spawn chunk per world")
            _player = newValue
        }
    }
    /// We put this in the world so it (i.e. what the player sees) is defined as part of the game
    /// ... and also because it's easy
    let playerCamera: PlayerCamera = PlayerCamera()
    let playerInput: PlayerInput

    private let _didUnloadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didLoadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didAddEntity: Publisher<Entity> = Publisher()
    private let _didRemoveEntity: Publisher<Entity> = Publisher()
    private let _didChangeSpeed: Publisher<()> = Publisher()
    private let _didTick: Publisher<()> = Publisher()
    var didUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didUnloadChunk) }
    var didLoadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didLoadChunk) }
    var didAddEntity: Observable<Entity> { Observable(publisher: _didAddEntity) }
    var didRemoveEntity: Observable<Entity> { Observable(publisher: _didRemoveEntity) }
    var didChangeSpeed: Observable<()> { Observable(publisher: _didChangeSpeed) }
    var didTick: Observable<()> { Observable(publisher: _didTick) }

    init(loader: WorldLoader, settings: WorldSettings, userSettings: UserSettings) {
        self.loader = loader
        self.settings = settings

        playerInput = PlayerInput(userSettings: userSettings)
        playerInput.world = self

        loadPlayer()
    }

    private func loadPlayer() {
        load(pos: loader.playerSpawnChunkPos)
        // TODO: Make this more graceful, throw a WorldCorruptionError, so loading bad worlds can't crash the game
        assert(_player != nil, "player spawn not in chunk pos, or player spawn didn't spawn player")
    }

    // region loading
    func loadAround(pos: CGPoint) {
        loadAround(pos: WorldTilePos.closestTo(pos: pos))
    }

    func loadAround(pos: WorldTilePos) {
        loadAround(pos: pos.worldChunkPos)
    }

    func loadAround(pos: WorldChunkPos) {
        load(pos: pos)
        for chunkPos in pos.adjacents.values {
            load(pos: chunkPos)
        }
    }

    func load(pos: CGPoint) {
        load(pos: WorldTilePos.closestTo(pos: pos))
    }

    func load(pos: WorldTilePos) {
        load(pos: pos.worldChunkPos)
    }

    func load(pos: WorldChunkPos) {
        if chunks[pos] == nil {
            // Actually load
            let chunk = loader.loadChunk(pos: pos)
            chunks[pos] = chunk

            // Remember we loaded this
            let loadedBefore = chunkPositionsLoadedBefore.contains(pos)
            chunkPositionsLoadedBefore.insert(pos)

            // Notify metadata
            if (!loadedBefore) {
                notifyAllMetadataInChunk(pos: pos, chunk: chunk) { $0.onFirstLoad }
            }
            notifyAllMetadataInChunk(pos: pos, chunk: chunk) { $0.onLoad }

            // Notify observers
            _didLoadChunk.publish((pos: pos, chunk: chunk))
        }
    }

    func unload(pos: WorldChunkPos) {
        assert(chunks[pos] != nil)
        let chunk = chunks[pos]!
        chunks[pos] = nil

        // Notify metadata
        notifyAllMetadataInChunk(pos: pos, chunk: chunk) { $0.onUnload }

        // Notify observers
        _didUnloadChunk.publish((pos: pos, chunk: chunk))
    }

    private func notifyAllMetadataInChunk(pos: WorldChunkPos, chunk: Chunk, getNotifyFunction: (TileMetadata) -> (World, WorldTilePos3D) -> ()) {
        for (chunkPos3D, metadata) in chunk.tileMetadatas {
            let pos3D = WorldTilePos3D(worldChunkPos: pos, chunkTilePos3D: chunkPos3D)
            let notifyThisMetadata = getNotifyFunction(metadata)
            notifyThisMetadata(self, pos3D)
        }
    }
    // endregion

    func tick() {
        // Tick the camera before entities because we want it to see the previous position
        playerCamera.tick(world: self)
        runActions()
        tickMetadatas()
        tickEntities()
        _didTick.publish()
    }

    // region tile access
    subscript(_ pos: WorldTilePos) -> [TileType] {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    subscript(_ pos3D: WorldTilePos3D) -> TileType {
        get {
            self[pos3D.pos][pos3D.layer]
        }
        set {
            let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
            chunk[pos3D.chunkTilePos3D] = newValue
        }
    }

    /// Places the tile, removing any non-overlapping tiles
    /// - Returns: The layer of the tile which was placed
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    func forceCreateTile(pos: WorldTilePos, type: TileType) -> Int {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        let layer = chunk.forcePlaceTileAndReturnLayer(pos: pos.chunkTilePos, type: type)
        let chunkPos3D = ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)
        // Notify metadata
        if let metadata = chunk.tileMetadatas[chunkPos3D] {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            metadata.onCreate(world: self, pos: pos3D)
        }
        return layer
    }

    /// Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    /// deletes the tile, while "remove" may mean it was unloaded
    func destroyTiles(pos: WorldTilePos) {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        let tileMetadatas: [(layer: Int, metadata: TileMetadata)] = (0..<Chunk.numLayers).compactMap { layer in
            let chunkPos3D = ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)
            if let metadata = chunk.tileMetadatas[chunkPos3D] {
                return (layer: layer, metadata: metadata)
            } else {
                return nil
            }
        }
        chunk.removeTiles(pos: pos.chunkTilePos)
        // Notify metadata
        for (layer, metadata) in tileMetadatas {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            metadata.onDestroy(world: self, pos: pos3D)
        }
    }

    private func getChunkAt(pos: WorldChunkPos) -> Chunk {
        load(pos: pos)
        return chunks[pos]!
    }
    // endregion

    // region metadatas
    private func tickMetadatas() {
        for (pos, metadata) in getLoadedMetadatas() {
            metadata.tick(world: self, pos: pos)
        }
    }

    private func getLoadedMetadatas() -> [(pos: WorldTilePos3D, metadata: TileMetadata)] {
        chunks.flatMap { (worldChunkPos, chunk) in
            chunk.tileMetadatas.map { (chunkPos3D, metadata) in
                let pos = WorldTilePos3D(worldChunkPos: worldChunkPos, chunkTilePos3D: chunkPos3D)
                return (pos: pos, metadata: metadata)
            }
        }
    }
    // endregion

    // region entities
    private func addNow(entity: Entity) {
        // Set entity world
        assert(entity.world === nil, "entity is already added to a world")
        entity.world = self
        entity.worldIndex = entities.count

        // Add to list
        entities.append(entity)

        // Notify observers
        _didAddEntity.publish(entity)
    }

    private func removeNow(entity: Entity) {

        // Set entity world
        assert(entity.world === self, "entity isn't in this world")
        entity.world = nil

        // Update others' world indices
        for entityAfterIndex in (entity.worldIndex + 1)..<entities.count {
            let entityAfter = entities[entityAfterIndex]
            entityAfter.worldIndex -= 1
        }

        // Remove from list
        entities.remove(at: entity.worldIndex)

        // Notify observers
        _didRemoveEntity.publish(entity)
    }

    private func tickEntities() {
        tickSystems()
        for entity in entities {
            entity.tick()
        }
    }

    private func tickSystems() {
        NinjaSystem.tick(world: self)
        ImplicitForcesSystem.tick(world: self)
        // Must be after ImplicitForcesSystem and NinjaSystem
        MovementSystem.tick(world: self)
        // Must be after MovementSystem
        CollisionSystem.tick(world: self)
        // Must be after CollisionSystem
        NearCollisionSystem.tick(world: self)
        // Must be after CollisionSystem
        OverlapSensitiveSystem.tick(world: self)
        // Must be after CollisionSystem
        AdjacentSensitiveSystem.tick(world: self)
        // Must be last
        LoadPositionSystem.tick(world: self)
    }
    // endregion

    // region actions
    private var entitiesToAdd: [Entity] = []
    private var entitiesToRemove: [Entity] = []

    func add(entity: Entity) {
        entitiesToAdd.append(entity)
    }

    func remove(entity: Entity) {
        entitiesToRemove.append(entity)
    }

    private func runActions() {
        for entity in entitiesToAdd {
            addNow(entity: entity)
        }
        entitiesToAdd.removeAll()
        for entity in entitiesToRemove {
            removeNow(entity: entity)
        }
        entitiesToRemove.removeAll()
    }
    // endregion
}
