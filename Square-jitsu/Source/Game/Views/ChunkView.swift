//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: NodeView {
    private var tileViews: ChunkMatrix<TileView?> = ChunkMatrix()
    private let world: World

    init(world: World, pos: WorldChunkPos, chunk: ReadonlyChunk) {
        self.world = world
        super.init(node: SKNode())

        placeExistingTiles(chunk: chunk)
        chunk.willPlaceTile.subscribe(observer: self, handler: placeTileView)
        chunk.willRemoveTile.subscribe(observer: self, handler: removeTileView)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    private func placeExistingTiles(chunk: ReadonlyChunk) {
        for tilePos in ChunkTilePos.allCases {
            let tilesAtPos = chunk[tilePos]
            for tileType in tilesAtPos {
                placeTileView(tilePos: tilePos, tileType: tileType)
            }
        }
    }

    func placeTileView(tilePos: ChunkTilePos, tileType: TileType) {
        let tileView = TileView(world: world, chunkPos: tilePos, tileType: tileType)
        tileView.place(parent: self.node)
        let _ = self.tileViews.insert(tileView, at: tilePos)
    }

    func removeTileView(tilePos: ChunkTilePos3D, tileType: TileType) {
        let tileView = self.tileViews[tilePos]!
        tileView.remove()
        self.tileViews.remove(at: tilePos)
    }
}
