//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class World: ReadonlyWorld, WritableStatelessWorld {
    private let loader: WorldLoader
    let settings: WorldSettings
    private weak var _conduit: WorldConduit?

    var conduit: WorldConduit {
        _conduit ?? StubWorldConduit()
    }

    // region chunks and associated data
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
    // endregion

    private(set) var numTicksSoFar: UInt64 = 0

    // region entities and associated data
    private(set) var entities: [Entity] = []

    /// Chunks whose bounds intersect this won't be unloaded
    var boundingBoxToPreventUnload: CGRect = CGRect.null
    // endregion

    // region speed
    var playerInputSpeedLerp: CGFloat = 0 {
        didSet { redetermineSpeed() }
    }
    private func redetermineSpeed() {
        let playerInputSpeedMultiplier = CGFloat.lerp(
            start: 1,
            end: settings.playerInputSpeedMultiplier,
            t: playerInputSpeedLerp
        )
        speed = playerInputSpeedMultiplier
    }
    /// Computed from the speed multipliers (add more for new effects which change speed)
    private(set) var speed: CGFloat = 1 {
        didSet {
            if speed != oldValue {
                _didChangeSpeed.publish()
            }
        }
    }
    // endregion

    // region player
    var playerBehavior: PlayerSpawnBehavior? = nil {
        willSet {
            assert(playerBehavior == nil, "playerMetadata can only be assigned once")
            assert(newValue != nil, "this is a redundant assignment of playerMetadata to nil, it's almost definitely wrong")
        }
    }
    private var _player: Entity? = nil
    var player: Entity {
        assert(_player != nil, "world isn't loaded yet, the player spawn chunk must be loaded, which loads the player spawn and sets the player entity")
        return _player!
    }
    /// We put this in the world so it (i.e. what the player sees) is defined as part of the game
    /// ... and also because it's easy
    let playerCamera: PlayerCamera
    let playerInput: PlayerInput
    // endregion

    /// The world itself doesn't handle editing and isn't affected by this,
    /// except that certain views with editor-useful info which are normally invisible are shown
    var showEditingIndicators: Bool = false {
        didSet { _didChangeEditorIndicatorVisibility.publish() }
    }

    // region observables
    private let _didReset: Publisher<()> = Publisher()
    private let _didUnloadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didLoadChunk: Publisher<(pos: WorldChunkPos, chunk: ReadonlyChunk)> = Publisher()
    private let _didAddEntity: Publisher<Entity> = Publisher()
    private let _didRemoveEntity: Publisher<Entity> = Publisher()
    private let _didChangeSpeed: Publisher<()> = Publisher()
    private let _didTick: Publisher<()> = Publisher()
    private let _didChangeEditorIndicatorVisibility: Publisher<()> = Publisher()
    /// Other notifications won't be fired on reset, only this one
    var didReset: Observable<()> { Observable(publisher: _didReset) }
    var didUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didUnloadChunk) }
    var didLoadChunk: Observable<(pos: WorldChunkPos, chunk: ReadonlyChunk)> { Observable(publisher: _didLoadChunk) }
    var didAddEntity: Observable<Entity> { Observable(publisher: _didAddEntity) }
    var didRemoveEntity: Observable<Entity> { Observable(publisher: _didRemoveEntity) }
    var didChangeSpeed: Observable<()> { Observable(publisher: _didChangeSpeed) }
    var didTick: Observable<()> { Observable(publisher: _didTick) }
    var didChangeEditorIndicatorVisibility: Observable<()> { Observable(publisher: _didChangeEditorIndicatorVisibility) }
    // endregion

    // region init
    init(loader: WorldLoader, settings: WorldSettings, userSettings: UserSettings, conduit: WorldConduit?) {
        self.loader = loader
        self.settings = settings
        _conduit = conduit

        playerCamera = PlayerCamera(userSettings: userSettings)
        playerInput = PlayerInput(userSettings: userSettings)

        playerCamera.world = self
        playerInput.world = self

        loadPlayer()
    }

    private func loadPlayer() {
        load(pos: loader.playerSpawnChunkPos)
        if playerBehavior == nil {
            Logger.warn("player spawn not in chunk pos, or player spawn didn't spawn player")
            playerBehavior = PlayerSpawnBehavior.dummyForInvalid(world: self)
        }
        _player = playerBehavior!.spawnPlayer()
        // This actually adds the player entity,
        // otherwise the player isn't visible first frame,
        // which is a problem since the editor initially loads the world paused
        // and thus it won't be visible until the user changes the mode
        runActions()
    }
    //endregion

    //region resetting
    func reset() {
        resetPlayer()
        resetExceptForPlayer()
    }

    func resetExceptForPlayer() {
        for (pos3D, metadata) in getLoadedMetadatas() {
            // We explicitly don't want to revert the player
            if !(metadata is PlayerSpawnBehavior) {
                metadata.revert(world: self, pos: pos3D)
            }
        }

        peekedChunks = [:]
        chunks = [:]
        persistentChunkData = [:]
        entitiesToAdd = []
        entitiesToRemove = []
        // Remove all entities except player
        if player.world === self {
            entities = [player]
            player.worldIndex = 0
        } else {
            entities = []
        }
        _didReset.publish()
        runActions()
    }

    func resetPlayer() {
        playerCamera.reset()
        // Otherwise player died so it's already removed
        if player.world === self {
            remove(entity: player)
        }
        _player = playerBehavior!.spawnPlayer()
        runActions() // Adds the player
    }

    /// Restores the player's health, and if they died,
    /// respawns them at the position where they died
    private func reanimatePlayer() {
        if player.world === nil {
            add(entity: player)
        }
        player.next.helC?.restoreAllHealth()
        runActions() // Necessary to actually trigger changes this frame
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

    func load(rect: CGRect) {
        for corner in rect.corners {
            load(pos: corner)
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
                persistentDataForChunk.overwrittenTileBehaviors = chunk.tileBehaviors
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

    private func notifyAllMetadataInChunk(pos: WorldChunkPos, chunk: Chunk, getNotifyFunction: (TileBehavior) -> (World, WorldTilePos3D) -> ()) {
        for (chunkPos3D, metadata) in chunk.tileBehaviors {
            let pos3D = WorldTilePos3D(worldChunkPos: pos, chunkTilePos3D: chunkPos3D)
            let notifyThisMetadata = getNotifyFunction(metadata)
            notifyThisMetadata(self, pos3D)
        }
    }
    // endregion

    func tick() {
        playerInput.tick()
        // Tick the camera before entities because we want it to see the previous position
        playerCamera.tick()
        runActions()
        tickMetadatas()
        tickEntities()

        _didTick.publish()

        numTicksSoFar += 1
    }

    // region tiles
    // region tile access
    subscript(_ pos: WorldTilePos) -> [TileType] {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    func _getTileTypeAt(pos3D: WorldTilePos3D) -> TileType {
        self[pos3D.pos][pos3D.layer]
    }

    func getNextFreeLayerAt(pos: WorldTilePos) -> Int? {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk.getNextFreeLayerAt(pos: pos.chunkTilePos)
    }

    func peek(pos: WorldTilePos) -> [TileType] {
        let chunk = peekLoad(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    func peek(pos3D: WorldTilePos3D) -> TileType {
        peek(pos: pos3D.pos)[pos3D.layer]
    }

    func getBehaviorAt(pos3D: WorldTilePos3D) -> TileBehavior? {
        let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
        return chunk.tileBehaviors[pos3D.chunkTilePos3D]
    }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata? {
        getBehaviorAt(pos3D: pos3D)?.untypedMetadata
    }

    private func getChunkAt(pos: WorldChunkPos) -> Chunk {
        load(pos: pos)
        return chunks[pos]!
    }
    // endregion

    // region tile mutation
    /// If you changed a tile and had the change persist,
    /// but want to revert the change to the same tile as the world loader provides,
    /// call this to clear the persistent data and then call
    /// `self[pos3D] = <#original#>`
    func resetStateAt(pos3D: WorldTilePos3D) {
        let persistentDataForChunk = persistentChunkData[pos3D.pos.worldChunkPos]!
        persistentDataForChunk.overwrittenTiles[pos3D.chunkTilePos3D] = nil
    }

    /// If you changed a tile and had the change persist,
    /// but want to revert the change to the same tile as the world loader provides,
    /// call this to clear the persistent data and then call
    /// `self[pos3D] = <#original#>`
    func resetStateAt(pos: WorldTilePos) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            resetStateAt(pos3D: pos3D)
        }
    }

    func setInternally(pos3D: WorldTilePos3D, to newType: TileType) {
        let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
        let chunkPos3D = pos3D.chunkTilePos3D
        chunk[chunkPos3D] = newType
    }

    func destroyTilesInternally(pos: WorldTilePos) {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        chunk.removeTiles(pos: pos.chunkTilePos)
    }

    func destroyTileInternally(pos3D: WorldTilePos3D) {
        let chunk = getChunkAt(pos: pos3D.pos.worldChunkPos)
        chunk[pos3D.chunkTilePos3D] = TileType.air
    }

    func finishChangingTileAt(pos3D: WorldTilePos3D, type: TileType) {
        assert(self[pos3D] == type)

        updatePersistentDataAt(pos3D: pos3D, type: type)
        notifyObserversOfAdjacentTileChanges(pos: pos3D.pos)
    }

    func finishCreatingTileAt(pos3D: WorldTilePos3D, type: TileType) {
        // Notify behavior to set metadata
        if let tileBehavior = getBehaviorAt(pos3D: pos3D) {
            tileBehavior.onCreate(world: self, pos3D: pos3D)
        }

        finishChangingTileAt(pos3D: pos3D, type: type)
    }

    func finishDestroyingTilesAt(pos: WorldTilePos) {
        destroyPersistentDataAt(pos: pos)
        notifyObserversOfAdjacentTileChanges(pos: pos)
    }

    private func updatePersistentDataAt(pos3D: WorldTilePos3D, type: TileType) {
        assert(self[pos3D] == type)

        let persistentDataForChunk = persistentChunkData[pos3D.pos.worldChunkPos]!
        let chunkPos3D = pos3D.chunkTilePos3D

        persistentDataForChunk.overwrittenTiles[chunkPos3D] = type
        persistentDataForChunk.overwrittenTileBehaviors[chunkPos3D] = getBehaviorAt(pos3D: pos3D)
    }

    private func destroyPersistentDataAt(pos: WorldTilePos) {
        // Update persistent data
        let persistentDataForChunk = persistentChunkData[pos.worldChunkPos]!
        for layer in 0..<Chunk.numLayers {
            let chunkPos3D = ChunkTilePos3D(pos: pos.chunkTilePos, layer: layer)

            persistentDataForChunk.overwrittenTiles[chunkPos3D] = TileType.air
            persistentDataForChunk.overwrittenTileBehaviors[chunkPos3D] = nil
        }
    }

    private func notifyBehaviorTileWasCreatedAt(pos3D: WorldTilePos3D) {
        let behavior = getBehaviorAt(pos3D: pos3D)
        behavior?.onCreate(world: self, pos3D: pos3D)
    }

    private func notifyObserversOfAdjacentTileChanges(pos: WorldTilePos) {
        // the observers are notified in the world because the adjacent tiles might be in another chunk than this tile,
        // and in that case that chunk should notify
        for adjacentPos in pos.cornerAdjacents.values {
            let chunkWithAdjacentPos = getChunkAt(pos: adjacentPos.worldChunkPos)
            chunkWithAdjacentPos._didAdjacentTileChange.publish(adjacentPos.chunkTilePos)
        }
    }
    // endregion

    // region metadatas
    private func tickMetadatas() {
        for (pos, metadata) in getLoadedMetadatas() {
            metadata.tick(world: self, pos: pos)
        }
    }

    private func getLoadedMetadatas() -> [(pos: WorldTilePos3D, metadata: TileBehavior)] {
        chunks.flatMap { (worldChunkPos, chunk) in
            chunk.tileBehaviors.map { (chunkPos3D, metadata) in
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

        tickEarlySystems(entity: entity)
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

    /// Runs systems which must be run before other systems, even though the order in `tick` is different
    private func tickEarlySystems(entity: Entity) {
        for system in EarlyTopLevelSystems {
            system.tickOnSpawn(entity: entity)
        }
    }

    private func tickSystems() {
        for system in TopLevelSystems {
            system.tick(world: self)
        }
    }
    // endregion

    // region actions
    private var entitiesToAdd: [Entity] = []
    private var entitiesToRemove: [Entity] = []

    func add(entity: Entity) {
        assert(entity.world === nil, "can't add entity because it's already added to a world: \(entity)")
        assert(!entitiesToAdd.contains(entity), "already adding this entity: \(entity)")
        entitiesToAdd.append(entity)
    }

    func remove(entity: Entity) {
        assert(entity.world === self, "can't remove entity because it isn't in this world: \(entity)")
        if !entitiesToRemove.contains(entity) {
            entitiesToRemove.append(entity)
        }
    }

    /// Necessary for grabs, although it's bad programming
    func expiditeAdd(entity: Entity) {
        assert(entitiesToAdd.contains(entity))
        addNow(entity: entity)
        entitiesToAdd.removeIfPresent(entity)
    }

    func runActions() {
        for entity in entitiesToAdd {
            addNow(entity: entity)
        }
        entitiesToAdd.removeAll()

        for system in OnDestroySystems {
            system.onDestroy(entities: entitiesToRemove)
        }
        for entity in entitiesToRemove {
            removeNow(entity: entity)
        }
        entitiesToRemove.removeAll()
    }
    // endregion

    func set(editorState: EditorState) {
        showEditingIndicators = editorState.showEditingIndicators
        if editorState == .editing {
            reanimatePlayer()
        }
    }
}
