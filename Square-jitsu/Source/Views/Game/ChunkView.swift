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
    private let glossMaskNode: SKNode?
    private let glossMaskChild: SKNode?

    init(world: ReadonlyWorld, pos: WorldChunkPos, chunk: ReadonlyChunk, glossMaskNode: SKNode?) {
        self.world = world
        self.chunk = chunk
        worldChunkPos = pos
        self.glossMaskNode = glossMaskNode
        glossMaskChild = glossMaskNode == nil ? nil : SKNode()
        super.init(node: SKNode())

        node.position = worldChunkPos.originCgPoint * world.settings.tileViewWidthHeight
        glossMaskChild?.position = worldChunkPos.originCgPoint * world.settings.tileViewWidthHeight

        placeExistingTiles(chunk: chunk)
        chunk.didChangeTile.subscribe(observer: self, priority: .view) { (self, chunkTilePos3DAndOldType) in
            let (chunkTilePos3D, _) = chunkTilePos3DAndOldType
            self.regenerateTileView(chunkTilePos3D: chunkTilePos3D)
        }
        chunk.didAdjacentTileChange.subscribe(observer: self, priority: .view) { (self, chunkTilePos) in
            self.regenerateTileViewsAt(chunkTilePos: chunkTilePos)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented - views nodes shouldn't be serialized")
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        glossMaskNode?.addChild(glossMaskChild!)
    }

    override func removeFromParent() {
        super.removeFromParent()
        glossMaskChild?.removeFromParent()
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
        if tileType != TileType.air {
            let worldTilePos3D = WorldTilePos3D(worldChunkPos: worldChunkPos, chunkTilePos3D: chunkTilePos3D)
            let tileView = TileView(world: world, pos3D: worldTilePos3D, tileType: tileType, coordinates: .chunk, glossMaskNode: glossMaskChild)
            tileView.placeIn(parent: node)
            tileViews[chunkTilePos3D] = tileView
        }
    }

    private func removeTileView(chunkTilePos3D: ChunkTilePos3D) {
        if let tileView = tileViews[chunkTilePos3D] {
            tileView.removeFromParent()
            tileViews[chunkTilePos3D] = nil
        }
    }

    private func hideTileAt(chunkTilePos3D: ChunkTilePos3D) {
        if let tileView = tileViews[chunkTilePos3D] {
            tileView.removeFromParent()
        }
    }

    private func showTileAt(chunkTilePos3D: ChunkTilePos3D) {
        if let tileView = tileViews[chunkTilePos3D] {
            tileView.placeIn(parent: node)
        }
    }
}
