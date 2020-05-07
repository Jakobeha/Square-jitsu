//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class Chunk: ReadonlyChunk {
    static let widthHeight: Int = 64
    static let numLayers: Int = 2

    private var tiles: ChunkMatrix<TileType> = ChunkMatrix()
    private(set) var tileMetadatas: [ChunkTilePos3D:TileMetadata] = [:]

    private let _willRemoveTile: Publisher<(pos: ChunkTilePos3D, tileType: TileType)> = Publisher()
    private let _willPlaceTile: Publisher<(pos: ChunkTilePos, tileType: TileType)> = Publisher()
    var willRemoveTile: Observable<(pos: ChunkTilePos3D, tileType: TileType)> { Observable(publisher: _willRemoveTile) }
    var willPlaceTile: Observable<(pos: ChunkTilePos, tileType: TileType)> { Observable(publisher: _willPlaceTile) }

    init() {
    }

    subscript(_ pos: ChunkTilePos) -> [TileType] {
        tiles[pos]
    }

    subscript(_ pos3D: ChunkTilePos3D) -> TileType {
        self[pos3D.pos][pos3D.layer]
    }

    /// Places the tile, removing any non-overlapping tiles
    /// - Returns: The layer of the tile which was placed
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    func forcePlaceTile(pos: ChunkTilePos, type: TileType) {
        let _ = forcePlaceTileAndReturnLayer(pos: pos, type: type)
    }

    /// Places the tile, removing any non-overlapping tiles
    /// - Returns: The layer of the tile which was placed
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
    func forcePlaceTileAndReturnLayer(pos: ChunkTilePos, type: TileType) -> Int {
        removeNonOverlappingTiles(pos: pos, type: type)
        assert(tiles.hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
        return placeTile(pos: pos, type: type)
    }

    /// - Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    ///   deletes the tile, while "remove" may mean it was unloaded
    func removeTiles(pos: ChunkTilePos) {
        let tilesAtPos = self[pos]

        // Notify observers
        for layer in (0..<Chunk.numLayers).reversed() {
            let tileType = tilesAtPos[layer]
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            _willRemoveTile.publish((pos: pos3D, tileType: tileType))
        }

        // Remove metadatas
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            tileMetadatas[pos3D] = nil
        }

        // Remove tiles
        tiles.removeAll(at: pos)
    }

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            let existingType = self[pos3D]
            if (!TileBigType.typesCanOverlap(type.bigType, existingType.bigType)) {
                removeTile(pos: pos3D)
            }
        }
    }

    private func removeTile(pos: ChunkTilePos3D) {
        let tileType = self[pos]

        // Notify observers
        _willRemoveTile.publish((pos: pos, tileType: tileType))

        // Remove metadata
        tileMetadatas[pos] = nil

        // Remove tile
        tiles.remove(at: pos)
    }

    /// - Returns: The layer of the tile which was placed
    private func placeTile(pos: ChunkTilePos, type: TileType) -> Int {
        // Get tile and metadata
        let metadata = TileMetadataForTileOf(type: type.bigType)

        // Place tile and add metadata
        _willPlaceTile.publish((pos: pos, tileType: type))
        let layer = tiles.insert(type, at: pos)
        if let metadata = metadata {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            tileMetadatas[pos3D] = metadata
        }

        return layer
    }
}
