//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: NodeView<SKNode> {
    private var tileViews: ChunkMatrix<TileView?> = ChunkMatrix()
    private let world: ReadonlyWorld
    private let chunk: ReadonlyChunk
    private let worldChunkPos: WorldChunkPos

    init(world: ReadonlyWorld, pos: WorldChunkPos, chunk: ReadonlyChunk) {
        self.world = world
        self.chunk = chunk
        worldChunkPos = pos
        super.init(node: SKNode())
        node.position = worldChunkPos.originCgPoint * world.settings.tileViewWidthHeight

        placeExistingTiles(chunk: chunk)
        chunk.didChangeTile.subscribe(observer: self, priority: ObservablePriority.view) { chunkTilePos3D, oldType in
            self.regenerateTileView(chunkTilePos3D: chunkTilePos3D)
        }
        chunk.didAdjacentTileChange.subscribe(observer: self, priority: ObservablePriority.view, handler: regenerateTileViewsAt)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func placeExistingTiles(chunk: ReadonlyChunk) {
        for tilePos3D in ChunkTilePos3D.allCases {
            placeTileView(chunkTilePos3D: tilePos3D)
        }
    }

    private func regenerateTileViewsAt(chunkTilePos: ChunkTilePos) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: chunkTilePos, layer: layer)
            regenerateTileView(chunkTilePos3D: pos3D)
        }
    }

    private func regenerateTileView(chunkTilePos3D: ChunkTilePos3D) {
        removeTileView(chunkTilePos3D: chunkTilePos3D)
        placeTileView(chunkTilePos3D: chunkTilePos3D)
    }

    private func placeTileView(chunkTilePos3D: ChunkTilePos3D) {
        assert(tileViews[chunkTilePos3D] == nil)
        let tileType = chunk[chunkTilePos3D]
        let worldTilePos = WorldTilePos(worldChunkPos: worldChunkPos, chunkTilePos: chunkTilePos3D.pos)
        let tileView = TileView(world: world, pos: worldTilePos, tileType: tileType, coordinates: .chunk)
        tileView.placeIn(parent: self.node)
        tileViews[chunkTilePos3D] = tileView
    }

    private func removeTileView(chunkTilePos3D: ChunkTilePos3D) {
        assert(tileViews[chunkTilePos3D] != nil)
        let tileView = tileViews[chunkTilePos3D]!
        tileView.removeFromParent()
        tileViews[chunkTilePos3D] = nil
    }

    private func hideTileAt(chunkTilePos3D: ChunkTilePos3D) {
        let tileView = tileViews[chunkTilePos3D]!
        tileView.removeFromParent()
    }

    private func showTileAt(chunkTilePos3D: ChunkTilePos3D) {
        let tileView = tileViews[chunkTilePos3D]!
        tileView.placeIn(parent: self.node)
    }
}
