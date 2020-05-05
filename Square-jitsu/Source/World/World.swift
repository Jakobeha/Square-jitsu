//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class World {
    private let loader: WorldLoader
    let settings: Settings
    private var chunks: [WorldChunkPos : Chunk] = [:]

    private(set) var entities: [Entity] = []

    private let _willUnloadChunk: Publisher<(pos: WorldChunkPos, chunk: ChunkObservable)> = Publisher()
    private let _willLoadChunk: Publisher<(pos: WorldChunkPos, chunk: ChunkObservable)> = Publisher()
    private let _willAddEntity: Publisher<Entity> = Publisher()
    private let _willRemoveEntity: Publisher<Entity> = Publisher()
    var willUnloadChunk: Observable<(pos: WorldChunkPos, chunk: ChunkObservable)> { Observable(publisher: _willUnloadChunk) }
    var willLoadChunk: Observable<(pos: WorldChunkPos, chunk: ChunkObservable)> { Observable(publisher: _willLoadChunk) }
    var willAddEntity: Observable<Entity> { Observable(publisher: _willAddEntity) }
    var willRemoveEntity: Observable<Entity> { Observable(publisher: _willRemoveEntity) }

    init(loader: WorldLoader, settings: Settings) {
        self.loader = loader
        self.settings = settings
    }

    // region loading
    func loadAround(pos: CGPoint) {
        loadAround(pos: WorldTilePos.closestTo(pos: pos))
    }

    func loadAround(pos: WorldTilePos) {
        load(pos: pos.worldChunkPos)
        for chunkPos in pos.worldChunkPos.adjacents.values {
            load(pos: chunkPos)
        }
    }

    func load(pos: WorldChunkPos) {
        if chunks[pos] != nil {
            let chunk = loader.loadChunk(pos: pos)
            _willLoadChunk.publish((pos: pos, chunk: chunk))
            chunks[pos] = chunk
        }
    }

    func unload(pos: WorldChunkPos) {
        assert(chunks[pos] != nil)
        let chunk = chunks[pos]!
        _willUnloadChunk.publish((pos: pos, chunk: chunk))
        chunks[pos] = nil
    }
    // endregion

    func tick() {
        runActions()
        tickEntities()
    }

    // region tile access
    subscript(_ pos: WorldTilePos) -> [Tile] {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk[pos.chunkTilePos]
    }

    /// Places the tile, removing any non-overlapping tiles
    func forcePlaceTile(pos: WorldTilePos, type: TileType) {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk.forcePlaceTile(pos: pos.chunkTilePos, type: type)
    }

    func removeTiles(pos: WorldTilePos) {
        let chunk = getChunkAt(pos: pos.worldChunkPos)
        return chunk.removeTiles(pos: pos.chunkTilePos)
    }

    private func getChunkAt(pos: WorldChunkPos) -> Chunk {
        load(pos: pos)
        return chunks[pos]!
    }
    // endregion

    // region entities
    private func addNow(entity: Entity) {
        assert(entity.world === nil, "entity is already added to a world")
        entity.world = self
        entity.worldIndex = entities.count
        _willAddEntity.publish(entity)
        entities.append(entity)
    }

    private func removeNow(entity: Entity) {
        assert(entity.world === self, "entity isn't in this world")
        _willRemoveEntity.publish(entity)
        entity.world = nil
    }

    private func tickEntities() {
        MovementSystem.tick(world: self)
        CollisionSystem.tick(world: self)
        LocationSystem.tick(world: self)
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
