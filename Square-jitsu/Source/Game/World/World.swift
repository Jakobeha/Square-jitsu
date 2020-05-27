//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class World: ReadonlyWorld {
    private let loader: WorldLoader
    let settings: WorldSettings
    /// Chunks which are only partially loaded.
    /// Peek-loading does not trigger observers or create metadata,
    /// and trying to access a tile in a peeked chunk will finish loading it
    /// unless done via peek(pos: ...). These are necessary to access adjacent tile data
    /// without preventing cascading loads
    private var peekedChunks: [WorldChunkPos : Chunk] = [:]
    private var chunks: [WorldChunkPos : Chunk] = [:]
    var readonlyChunks: [WorldChunkPos : ReadonlyChunk] {
        chunks.mapValues { $0 as ReadonlyChunk }
    }
    private var persistentChunkData: [WorldChunkPos:GamePersistentChunkData] = [:]

    private(set) var entities: [Entity] = []

    /// Chunks whose bounds intersect this won't be unloaded
    var boundingBoxToPreventUnload: CGRect = CGRect.null

    var speed: CGFloat = 1 {
        didSet {
            _didChangeSpeed.publish()
        }
    }

    private var _playerMetadata: PlayerSpawnMetadata? = nil
    var playerMetadata: PlayerSpawnMetadata {
        get { _playerMetadata! }
        set {
            if _playerMetadata != nil {
                Logger.warn("player already loaded, one player spawn chunk per world, not setting this field")
            } else {
                _playerMetadata = newValue
            }
        }
    }
    private var _player: Entity? = nil
    var player: Entity {
            assert(_player != nil, "world isn't loaded yet, the player spawn chunk must be loaded, which loads the player spawn and sets the player entity")
            return _player!
    }
    /// We put this in the world so it (i.e. what the player sees) is defined as part of the game
    /// ... and also because it's easy
    let playerCamera: PlayerCamera = PlayerCamera()
    let playerInput: PlayerInput

    private let _didReset: Publisher<()> = Publisher()
    private let _didUnloadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didLoadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didAddEntity: Publisher<Entity> = Publisher()
    private let _didRemoveEntity: Publisher<Entity> = Publisher()
    private let _didChangeSpeed: Publisher<()> = Publisher()
    private let _didTick: Publisher<()> = Publisher()
    /// Other notifications won't be fired on reset, only this one
    var didReset: Observable<()> { Observable(publisher: _didReset) }
    var didUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didUnloadChunk) }
    var didLoadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didLoadChunk) }
    var didAddEntity: Observable<Entity> { Observable(publisher: _didAddEntity) }
    var didRemoveEntity: Observable<Entity> { Observable(publisher: _didRemoveEntity) }
    var didChangeSpeed: Observable<()> { Observable(publisher: _didChangeSpeed) }
    var didTick: Observable<()> { Observable(publisher: _didTick) }

    // region init
    init(loader: WorldLoader, settings: WorldSettings, userSettings: UserSettings) {
        self.loader = loader
        self.settings = settings

        playerInput = PlayerInput(userSettings: userSettings)
        playerInput.world = self

        loadPlayer()
    }

    private func loadPlayer() {
        load(pos: loader.playerSpawnChunkPos)
        if _playerMetadata == nil {
            Logger.warn("player spawn not in chunk pos, or player spawn didn't spawn player")
            _playerMetadata = PlayerSpawnMetadata.dummyForInvalid(world: self)
        }
        _player = playerMetadata.spawnPlayer()
        // This actually adds the player entity,
        // otherwise the player isn't visible first frame,
        // which is a problem since the editor initially loads the world paused
        // and thus it won't be visible until the user changes the mode
        tick()
    }
    //endregion

    //region resetting
    func reset() {
        resetPlayer()
        resetExceptForPlayer()
    }

    func resetExceptForPlayer() {
        // Unload all chunks except for 
        let playerSpawnChunk = getChunkAt(pos: loader.playerSpawnChunkPos)
        let persistentPlayerSpawnChunkData = persistentChunkData[loader.playerSpawnChunkPos]!

        peekedChunks = [:]
        chunks = [loader.playerSpawnChunkPos:playerSpawnChunk]
        persistentChunkData = [loader.playerSpawnChunkPos:persistentPlayerSpawnChunkData]
        speed = 1
        entitiesToAdd = []
        entitiesToRemove = []
        entities = [player]
    }

    func resetPlayer() {
        remove(entity: player)
        _player = playerMetadata.spawnPlayer()
    }
    //endregion

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
            // Actually load, or used peeked chunk (and clear peeked)
            print("Load \(pos)")
            let chunk = peekedChunks[pos] ?? loader.loadChunk(pos: pos)
            peekedChunks[pos] = nil
            chunks[pos] = chunk

            // Remember whether we loaded this before, and the persistent data if so
            let existingPersistentChunkData = persistentChunkData[pos]
            let loadedBefore = existingPersistentChunkData != nil

            // Apply persistent overwrites
            if let prevPersistentChunk = existingPersistentChunkData {
                prevPersistentChunk.apply(to: chunk)
            }

            // Notify metadata
            if !loadedBefore {
                let persistentDataForChunk = GamePersistentChunkData()
                persistentDataForChunk.overwrittenTileMetadatas = chunk.tileMetadatas
                persistentChunkData[pos] = persistentDataForChunk
                notifyAllMetadataInChunk(pos: pos, chunk: chunk) { $0.onFirstLoad }
            }

            // Notify observers
            _didLoadChunk.publish((pos: pos, chunk: chunk))
        }
    }

    func peekLoad(pos: WorldTilePos) -> Chunk {
        peekLoad(pos: pos.worldChunkPos)
    }

    func peekLoad(pos: WorldChunkPos) -> Chunk {
        // Try preloaded
        if let chunk = chunks[pos] ?? peekedChunks[pos] {
            return chunk
        } else {
            // Actually load
            print("Peek \(pos)")
            let chunk = loader.loadChunk(pos: pos)
            peekedChunks[pos] = chunk
            return chunk
        }
    }

    func unloadUnnecessaryChunks() {
        if !boundingBoxToPreventUnload.isNull {
            var positionsToUnload: [WorldChunkPos] = []
            for chunkPosition in chunks.keys {
                let chunkBounds = chunkPosition.cgBounds
                if !boundingBoxToPreventUnload.intersects(chunkBounds) {
                    positionsToUnload.append(chunkPosition)
                }
            }
            for positionToUnload in positionsToUnload {
                unload(pos: positionToUnload)
            }
        }
    }

    func unload(pos: WorldChunkPos) {
        if chunks[pos] != nil {
            print("Unload \(pos)")
            let chunk = chunks[pos]!
            chunks[pos] = nil

            // Notify observers
            _didUnloadChunk.publish((pos: pos, chunk: chunk))
        }
        if peekedChunks[pos] != nil {
            peekedChunks[pos] = nil
        }
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

    // region tiles
    // region tile access
    subscript(_ pos: WorldTilePos) -> [TileType] {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    subscript(_ pos3D: WorldTilePos3D) -> TileType {
        self[pos3D.pos][pos3D.layer]
    }

    func peek(pos: WorldTilePos) -> [TileType] {
        let chunk = peekLoad(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    func peek(pos3D: WorldTilePos3D) -> TileType {
        peek(pos: pos3D.pos)[pos3D.layer]
    }
    // endregion

    // region tile mutation
    func set(pos3D: WorldTilePos3D, to newType: TileType, persistInGame: Bool) {
        // Set in chunk (actual read data)
        let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
        let chunkPos3D = pos3D.chunkTilePos3D
        chunk[chunkPos3D] = newType

        // Set in persistent data
        let persistentDataForChunk = persistentChunkData[pos3D.pos.worldChunkPos]!
        if persistInGame {
            persistentDataForChunk.overwrittenTiles[chunkPos3D] = newType
        }
        persistentDataForChunk.overwrittenTileMetadatas[chunkPos3D] = chunk.tileMetadatas[chunkPos3D]

        notifyObserversOfAdjacentTileChanges(pos: pos3D.pos)
    }

    func getMetadatasAt(pos: WorldTilePos) -> [(layer: Int, tileMetadata: TileMetadata)] {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk.getMetadatasAt(pos: pos.chunkTilePos)
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
        return chunk.tileMetadatas[pos3D.chunkTilePos3D]
    }

    /// Places the tile, removing any non-overlapping tiles
    /// - Returns: The layer of the tile which was placed
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    @discardableResult func forceCreateTile(pos: WorldTilePos, type: TileType) -> Int {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        let layer = chunk.forcePlaceTile(pos: pos.chunkTilePos, type: type)

        // Update metadata persistence
        let persistentDataForChunk = persistentChunkData[pos.worldChunkPos]!
        for layer in 0..<Chunk.numLayers {
            let chunkPos3D = ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)
            persistentDataForChunk.overwrittenTileMetadatas[chunkPos3D] = chunk.tileMetadatas[chunkPos3D]
        }

        notifyObserversOfAdjacentTileChanges(pos: pos)

        return layer
    }

    /// Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    /// deletes the tile, while "remove" may mean it was unloaded
    func destroyTiles(pos: WorldTilePos) {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        chunk.removeTiles(pos: pos.chunkTilePos)

        // Update metadata persistence
        let persistentDataForChunk = persistentChunkData[pos.worldChunkPos]!
        for layer in 0..<Chunk.numLayers {
            let chunkPos3D = ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)
            persistentDataForChunk.overwrittenTileMetadatas[chunkPos3D] = nil
        }

        notifyObserversOfAdjacentTileChanges(pos: pos)
    }

    private func notifyObserversOfAdjacentTileChanges(pos: WorldTilePos) {
        // the observers are notified in the world because the adjacent tiles might be in another chunk than this tile,
        // and in that case that chunk should notify
        for adjacentPos in pos.cornerAdjacents.values {
            let chunkWithAdjacentPos = getChunkAt(pos: adjacentPos.worldChunkPos)
            chunkWithAdjacentPos._didAdjacentTileChange.publish(adjacentPos.chunkTilePos)
        }
    }

    private func getChunkAt(pos: WorldChunkPos) -> Chunk {
        load(pos: pos)
        return chunks[pos]!
    }
    // endregion

    // region advanced tile access
    /// Note: doesn't return nil for air
    func sideAdjacentsWithSameTypeAsTileAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        let type = self[pos3D]

        return getConnectedSideAdjacents(origin: pos3D) { testPos in
            let typesAtPos = self[testPos]
            // Technically it doesn't matter whether we use firstIndex or lastIndex
            if let indexWithSameTypeAtPos = typesAtPos.lastIndex(of: type) {
                return [indexWithSameTypeAtPos]
            } else {
                return []
            }
        }
    }

    // Return a set of all positions "connected" to the origin (including it), according to the predicate
    private func getConnectedSideAdjacents(origin: WorldTilePos3D, getConnectedLayers: (WorldTilePos) -> [Int]) -> Set<WorldTilePos3D> {
        var positions3D: Set<WorldTilePos3D> = [origin]

        var positions2DAtPrevDistance: Set<WorldTilePos> = [origin.pos]
        var distance = 0
        while !positions2DAtPrevDistance.isEmpty {
            distance += 1
            var positions2DAtNextDistance: Set<WorldTilePos> = []
            var maybeConnectedPositions2DAtNextDistance: Set<WorldTilePos> = []
            var maybeConnectedPositions3D: Set<WorldTilePos3D> = []

            for pos in WorldTilePos.sweepSquare(center: origin.pos, distance: distance) {
                // Technically it doesn't matter whether we use firstIndex or lastIndex
                let connectedLayers = getConnectedLayers(pos)
                for layer in connectedLayers {
                    // The world has a tile of the same type at this position - else it doesn't
                    let pos3D = WorldTilePos3D(pos: pos, layer: layer)
                    if positions2DAtPrevDistance.contains(anyOf: pos.sideAdjacents.values) {
                        // The tile is connected to pos3D, add it.
                        // Also all maybe positions are also connected, from transitivity
                        positions2DAtNextDistance.insert(pos)
                        positions3D.insert(pos3D)
                        positions2DAtNextDistance.formUnion(maybeConnectedPositions2DAtNextDistance)
                        maybeConnectedPositions3D.insert(pos3D)
                        maybeConnectedPositions2DAtNextDistance.removeAll()
                        maybeConnectedPositions3D.removeAll()
                    } else {
                        // The tile may not be connected, or maybe it will be connected to another connected tile at
                        // this layer, and thus transitively connected
                        maybeConnectedPositions2DAtNextDistance.insert(pos)
                        maybeConnectedPositions3D.insert(pos3D)
                    }
                }
                if !connectedLayers.isEmpty {
                    // The maybe-connected tiles aren't actually connected
                    maybeConnectedPositions2DAtNextDistance.removeAll()
                    maybeConnectedPositions3D.removeAll()
                }
            }

            positions2DAtPrevDistance = positions2DAtNextDistance
        }

        return positions3D
    }
    // endregion

    // region tile showing / hiding
    func temporarilyHide(positions: Set<WorldTilePos3D>) {
        let tilesInChunks = WorldTilePos3D.groupByChunkPositions(positions)
        for (worldChunkPos, chunkTilePositions) in tilesInChunks {
            let chunk = getChunkAt(pos: worldChunkPos)
            chunk.hide(positions: chunkTilePositions)
        }
    }

    func showTemporarilyHidden(positions: Set<WorldTilePos3D>) {
        let tilesInChunks = WorldTilePos3D.groupByChunkPositions(positions)
        for (worldChunkPos, chunkTilePositions) in tilesInChunks {
            let chunk = getChunkAt(pos: worldChunkPos)
            chunk.showHidden(positions: chunkTilePositions)
        }
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
        // Must be after CollisionSystem
        TurretSystem.tick(world: self)
        // Must be after CollisionSystem
        GrabSystem.tick(world: self)
        // Must be after CollisionSystem
        DamageSystem.tick(world: self)
        // Must be last
        LoadPositionSystem.tick(world: self)
    }
    // endregion

    // region actions
    private var entitiesToAdd: [Entity] = []
    private var entitiesToRemove: [Entity] = []

    func add(entity: Entity) {
        assert(!entitiesToAdd.contains(entity))
        entitiesToAdd.append(entity)
    }

    func remove(entity: Entity) {
        if !entitiesToRemove.contains(entity) {
            entitiesToRemove.append(entity)
        }
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
