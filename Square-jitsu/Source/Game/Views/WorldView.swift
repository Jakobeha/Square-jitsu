//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class WorldView: View {
    private var chunkViews: [WorldChunkPos:ChunkView] = [:]
    private let world: World

    private let node: SKNode = SKNode()

    init(world: World) {
        self.world = world
        super.init()

        placeExistingChunks()
        world.willLoadChunk.subscribe(observer: self, handler: placeChunkView)
        world.willUnloadChunk.subscribe(observer: self, handler: removeChunkView)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func placeExistingChunks() {
        for (pos, chunk) in world.readonlyChunks {
            placeChunkView(pos: pos, chunk: chunk)
        }
    }

    func placeChunkView(pos: WorldChunkPos, chunk: ReadonlyChunk) {
        let chunkView = ChunkView(world: world, pos: pos, chunk: chunk)
        chunkView.place(parent: self.node)
        self.chunkViews[pos] = chunkView
    }

    func removeChunkView(pos: WorldChunkPos, chunk: ReadonlyChunk) {
        let chunkView = self.chunkViews[pos]!
        chunkView.remove()
        self.chunkViews[pos] = nil
    }
}
