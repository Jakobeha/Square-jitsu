//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: NodeView {
    private var tileViews: ChunkMatrix<TileView?> = ChunkMatrix()
    private let world: World
    private let chunk: ReadonlyChunk
    private let worldChunkPos: WorldChunkPos

    init(world: World, pos: WorldChunkPos, chunk: ReadonlyChunk) {
        self.world = world
        self.chunk = chunk
        worldChunkPos = pos
        super.init(node: SKNode())
        node.position = worldChunkPos.originCgPoint * world.settings.tileViewWidthHeight

        placeExistingTiles(chunk: chunk)
        chunk.didPlaceTile.subscribe(observer: self, handler: placeTileView)
        chunk.didRemoveTile.subscribe(observer: self, handler: removeTileView)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func placeExistingTiles(chunk: ReadonlyChunk) {
        for tilePos3D in ChunkTilePos3D.allCases {
            placeTileView(chunkTilePos3D: tilePos3D)
        }
    }

    func placeTileView(chunkTilePos3D: ChunkTilePos3D) {
        assert(tileViews[chunkTilePos3D] == nil)
        let tileType = chunk[chunkTilePos3D]
        let worldTilePos = WorldTilePos(worldChunkPos: worldChunkPos, chunkTilePos: chunkTilePos3D.pos)
        let tileView = TileView(world: world, pos: worldTilePos, tileType: tileType)
        tileView.placeIn(parent: self.node)
        tileViews[chunkTilePos3D] = tileView
    }

    func removeTileView(tilePos3D: ChunkTilePos3D, oldType: TileType) {
        assert(tileViews[tilePos3D] != nil)
        let tileView = tileViews[tilePos3D]!
        tileView.removeFromParent()
        tileViews[tilePos3D] = nil
    }
}
