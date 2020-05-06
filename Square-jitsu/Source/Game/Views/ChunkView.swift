//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ChunkView: View {
    private var tileViews: ChunkMatrix<TileView?> = ChunkMatrix()
    private let world: World

    private let node: SKNode = SKNode()

    init(world: World, pos: WorldChunkPos, chunk: ReadonlyChunk) {
        self.world = world
        super.init()

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
            for tile in tilesAtPos {
                placeTileView(tilePos: tilePos, tile: tile)
            }
        }
    }

    func placeTileView(tilePos: ChunkTilePos, tile: Tile) {
        let tileView = TileView(world: world, chunkPos: tilePos, tile: tile)
        tileView.place(parent: self.node)
        self.tileViews.insert(tileView, at: tilePos)
    }

    func removeTileView(tilePos: ChunkTilePos, layer: Int, tile: Tile) {
        let tileView = self.tileViews[tilePos][layer]!
        tileView.remove()
        self.tileViews.remove(at: tilePos, layer: layer)
    }
}
