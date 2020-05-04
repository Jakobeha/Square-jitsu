//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Chunk {
    static let widthHeight: Int = 64
    static let numLayers: Int = 2

    private var tiles: [[[Tile]]] = [[[Tile]]](repeating: [[Tile]](repeating: [Tile](repeating: Tile.air, count: numLayers), count: widthHeight), count: widthHeight)
    private var tileMetadatas: [TileMetadata] = []

    init() {
    }

    subscript(_ pos: ChunkTilePos) -> [Tile] {
        tiles[pos.x][pos.y]
    }

    /// Places the tile, removing any non-overlapping tiles
    func forcePlaceTile(pos: ChunkTilePos, type: TileType) {
        removeNonOverlappingTiles(pos: pos, type: type)
        assert(hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
        placeTile(pos: pos, type: type)
    }

    func removeTiles(pos: ChunkTilePos) {
        let tilesAtPos = self[pos]
        for tile in tilesAtPos {
            if (!tile.id.isAnonymous) {
                tileMetadatas.remove(at: tile.id.index)
            }
        }

        // Move later tiles down, so the last layers are the empty ones
        for layer in 0..<Chunk.numLayers {
            tiles[pos.x][pos.y][layer] = Tile.air
        }
    }

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let existingType = self[pos][layer].type
            if (!TileType.typesCanOverlap(type, existingType)) {
                removeTile(pos: pos, layer: layer)
            }
        }
    }

    private func removeTile(pos: ChunkTilePos, layer: Int) {
        let tilesAtPos = self[pos]
        let tile = tilesAtPos[layer]
        if (!tile.id.isAnonymous) {
            tileMetadatas.remove(at: tile.id.index)
        }

        // Move later tiles down, so the last layers are the empty ones
        for nextLayer in layer..<(Chunk.numLayers - 1) {
            tiles[pos.x][pos.y][nextLayer] = tilesAtPos[nextLayer + 1]
        }
        tiles[pos.x][pos.y][Chunk.numLayers - 1] = Tile.air
    }

    private func placeTile(pos: ChunkTilePos, type: TileType) {
        let layer = getNextFreeLayerAt(pos: pos) ?? {
            fatalError("can't place tile because this position is occupied")
        }()

        let metadata = TileMetadataForTileOf(type: type.bigType)

        // If there is metadata, a) the tile has an id, and b) we add it to tileMetadatas. tileMetadatas.count will be its index
        // If there is no metadata, the tile is anonymous
        let id = (metadata == nil) ? TileId.anonymous : TileId.forIndex(tileMetadatas.count)
        if let metadata = metadata {
            tileMetadatas.append(metadata)
        }

        let tile = Tile(type: type, id: id)
        tiles[pos.x][pos.y][layer] = tile
    }

    private func getNextFreeLayerAt(pos: ChunkTilePos) -> Int? {
        let tilesAtPos = tiles[pos.x][pos.y]
        var guess = 0
        while (tilesAtPos[guess] != Tile.air) {
            guess += 1
            if (guess == tilesAtPos.count) {
                return nil
            }
        }
        return guess
    }

    private func hasFreeLayerAt(pos: ChunkTilePos) -> Bool {
        getNextFreeLayerAt(pos: pos) != nil
    }
}
