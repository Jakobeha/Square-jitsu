//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class WorldView: NodeView<SKNode> {
    private var chunkViews: [WorldChunkPos:ChunkView] = [:]
    private var entityViews: [EntityView] = []
    private let world: ReadonlyWorld

    init(world: ReadonlyWorld) {
        self.world = world
        super.init(node: SKNode())

        placeExisting()
        world.didReset.subscribe(observer: self, priority: .view, handler: reSynchronize)
        world.didLoadChunk.subscribe(observer: self, priority: .view, handler: placeChunkView)
        world.didUnloadChunk.subscribe(observer: self, priority: .view, handler: removeChunkView)
        world.didAddEntity.subscribe(observer: self, priority: .view, handler: placeEntityView)
        world.didRemoveEntity.subscribe(observer: self, priority: .view, handler: removeEntityView)
        world.didTick.subscribe(observer: self, priority: .view, handler: update)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func reSynchronize() {
        removeAllChildren()
        placeExisting()
    }

    private func removeAllChildren() {
        for chunkView in chunkViews.values {
            chunkView.removeFromParent()
        }
        for entityView in entityViews {
            entityView.removeFromParent()
        }
        chunkViews.removeAll()
        entityViews.removeAll()
    }

    private func placeExisting() {
        placeExistingChunks()
        placeExistingEntities()
    }

    private func placeExistingChunks() {
        for (pos, chunk) in world.readonlyChunks {
            placeChunkView(pos: pos, chunk: chunk)
        }
    }

    private func placeExistingEntities() {
        for entity in world.entities {
            placeEntityView(entity: entity)
        }
    }

    func placeChunkView(pos: WorldChunkPos, chunk: ReadonlyChunk) {
        assert(chunkViews[pos] == nil)
        let chunkView = ChunkView(world: world, pos: pos, chunk: chunk)
        chunkView.placeIn(parent: self.node)
        chunkViews[pos] = chunkView
    }

    func removeChunkView(pos: WorldChunkPos, chunk: ReadonlyChunk) {
        assert(chunkViews[pos] != nil)
        let chunkView = chunkViews[pos]!
        chunkView.removeFromParent()
        chunkViews[pos] = nil
    }

    func placeEntityView(entity: Entity) {
        let entityView = EntityView(entity: entity)
        entityView.placeIn(parent: self.node)
        self.entityViews.append(entityView)
    }

    func removeEntityView(entity: Entity) {
        let entityView = self.entityViews[entity.worldIndex]
        entityView.removeFromParent()
        self.entityViews.remove(at: entity.worldIndex)
    }

    func update() {
        for entityView in entityViews {
            entityView.update()
        }
    }
}
