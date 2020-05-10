//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: NodeView {
    private var tileViews: ChunkMatrix<TileView?> = ChunkMatrix()
    private let world: World
    private let chunk: ReadonlyChunk

    init(world: World, pos: WorldChunkPos, chunk: ReadonlyChunk) {
        self.world = world
        self.chunk = chunk
        super.init(node: SKNode())
        node.position = pos.originCgPoint * world.settings.tileViewWidthHeight

        placeExistingTiles(chunk: chunk)
        chunk.didPlaceTile.subscribe(observer: self, handler: placeTileView)
        chunk.didRemoveTile.subscribe(observer: self, handler: removeTileView)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func placeExistingTiles(chunk: ReadonlyChunk) {
        for tilePos3D in ChunkTilePos3D.allCases {
            placeTileView(tilePos3D: tilePos3D)
        }
    }

    func placeTileView(tilePos3D: ChunkTilePos3D) {
        assert(tileViews[tilePos3D] == nil)
        let tileType = chunk[tilePos3D]
        let tileView = TileView(world: world, chunkPos: tilePos3D.pos, tileType: tileType)
        tileView.placeIn(parent: self.node)
        tileViews[tilePos3D] = tileView
    }

    func removeTileView(tilePos3D: ChunkTilePos3D, oldType: TileType) {
        assert(tileViews[tilePos3D] != nil)
        let tileView = tileViews[tilePos3D]!
        tileView.removeFromParent()
        tileViews[tilePos3D] = nil
    }
}
