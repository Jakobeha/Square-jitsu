//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Chunk: ReadonlyChunk {
    static let widthHeight: Int = 64
    static let numLayers: Int = 2

    private var tiles: ChunkMatrix<Tile> = ChunkMatrix()
    private(set) var tileMetadatas: [TileMetadataAndPos] = []

    private let _willRemoveTile: Publisher<(pos: ChunkTilePos, layer: Int, tile: Tile)> = Publisher()
    private let _willPlaceTile: Publisher<(pos: ChunkTilePos, tile: Tile)> = Publisher()
    var willRemoveTile: Observable<(pos: ChunkTilePos, layer: Int, tile: Tile)> { Observable(publisher: _willRemoveTile) }
    var willPlaceTile: Observable<(pos: ChunkTilePos, tile: Tile)> { Observable(publisher: _willPlaceTile) }

    init() {
    }

    subscript(_ pos: ChunkTilePos) -> [Tile] {
        tiles[pos]
    }

    func getTileMetadataFor(tile: Tile) -> TileMetadataAndPos? {
        getTileMetadataFor(tileId: tile.id)
    }

    private func getTileMetadataFor(tileId: TileId) -> TileMetadataAndPos? {
        tileId.isAnonymous ? nil : tileMetadatas[tileId.index]
    }

    /// Places the tile, removing any non-overlapping tiles
    /// Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    /// places the tile, while "place" may mean it was loaded
    func forcePlaceTile(pos: ChunkTilePos, type: TileType) -> (tile: Tile, layer: Int) {
        removeNonOverlappingTiles(pos: pos, type: type)
        assert(tiles.hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
        return placeTile(pos: pos, type: type)
    }

    /// Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    /// deletes the tile, while "remove" may mean it was unloaded
    func removeTiles(pos: ChunkTilePos) {
        let tilesAtPos = self[pos]

        for layer in (0..<Chunk.numLayers).reversed() {
            let tile = tilesAtPos[layer]
            _willRemoveTile.publish((pos: pos, layer: layer, tile: tile))
        }

        for tile in tilesAtPos {
            if (!tile.id.isAnonymous) {
                tileMetadatas.remove(at: tile.id.index)
            }
        }


        tiles.removeAll(at: pos)
    }

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let existingType = self[pos][layer].type
            if (!TileBigType.typesCanOverlap(type.bigType, existingType.bigType)) {
                removeTile(pos: pos, layer: layer)
            }
        }
    }

    private func removeTile(pos: ChunkTilePos, layer: Int) {
        let tilesAtPos = self[pos]
        let tile = tilesAtPos[layer]

        _willRemoveTile.publish((pos: pos, layer: layer, tile: tile))

        if (!tile.id.isAnonymous) {
            tileMetadatas.remove(at: tile.id.index)
        }

        tiles.remove(at: pos, layer: layer)
    }

    private func placeTile(pos: ChunkTilePos, type: TileType) -> (tile: Tile, layer: Int) {
        // Get tile and metadata
        let metadata = TileMetadataForTileOf(type: type.bigType)
        // If there is metadata, a) the tile has an id, and b) we add it to tileMetadatas. tileMetadatas.count will be its index
        // If there is no metadata, the tile is anonymous
        let id = (metadata == nil) ? TileId.anonymous : TileId.forIndex(tileMetadatas.count)
        let tile = Tile(type: type, id: id)

        // Place tile and add metadata
        _willPlaceTile.publish((pos: pos, tile: tile))
        let layer = tiles.insert(tile, at: pos)
        if let metadata = metadata {
            tileMetadatas.append(TileMetadataAndPos(metadata: metadata, chunkPos: pos, layer: layer))
        }

        return (tile: tile, layer: layer)
    }
}
