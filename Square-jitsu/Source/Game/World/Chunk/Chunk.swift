//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class Chunk: ReadonlyChunk {
    static let widthHeight: Int = 64
    static let numLayers: Int = 2

    static let cgSize: CGSize = CGSize.square(sideLength: CGFloat(Chunk.widthHeight))

    private var tiles: ChunkMatrix<TileType> = ChunkMatrix()
    private(set) var tileMetadatas: [ChunkTilePos3D:TileMetadata] = [:]

    private let _didRemoveTile: Publisher<(pos3D: ChunkTilePos3D, oldType: TileType)> = Publisher()
    private let _didPlaceTile: Publisher<ChunkTilePos3D> = Publisher()
    var didRemoveTile: Observable<(pos3D: ChunkTilePos3D, oldType: TileType)> { Observable(publisher: _didRemoveTile) }
    var didPlaceTile: Observable<ChunkTilePos3D> { Observable(publisher: _didPlaceTile) }

    init() {
    }

    subscript(_ pos: ChunkTilePos) -> [TileType] {
        tiles[pos]
    }

    subscript(_ pos3D: ChunkTilePos3D) -> TileType {
        get {
            tiles[pos3D]
        }
        set {
            let oldType = self[pos3D]
            tiles[pos3D] = newValue
            _didRemoveTile.publish((pos3D: pos3D, oldType: oldType))
            _didPlaceTile.publish(pos3D)
        }
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

        // Remove metadatas
        for layer in 0..<Chunk.numLayers {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            tileMetadatas[pos3D] = nil
        }

        // Remove tiles
        tiles.removeAll(at: pos)

        // Notify observers
        for layer in 0..<Chunk.numLayers {
            let oldType = tilesAtPos[layer]
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            _didRemoveTile.publish((pos3D: pos3D, oldType: oldType))
        }
    }

    private func removeNonOverlappingTiles(pos: ChunkTilePos, type: TileType) {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
            let existingType = self[pos3D]
            if (!TileBigType.typesCanOverlap(type.bigType, existingType.bigType)) {
                removeTile(pos3D: pos3D)
            }
        }
    }

    private func removeTile(pos3D: ChunkTilePos3D) {
        let tileType = self[pos3D]

        // Remove metadata
        tileMetadatas[pos3D] = nil

        // Remove tile
        tiles.remove(at: pos3D)

        // Notify observers
        _didRemoveTile.publish((pos3D: pos3D, oldType: tileType))
    }

    /// - Returns: The layer of the tile which was placed
    private func placeTile(pos: ChunkTilePos, type: TileType) -> Int {
        // Get tile and metadata
        let metadata = type.bigType.newMetadata()

        // Place tile and add metadata
        let layer = tiles.insert(type, at: pos)
        let pos3D = ChunkTilePos3D(pos: pos, layer: layer)
        if let metadata = metadata {
            tileMetadatas[pos3D] = metadata
        }

        // Notify observers
        _didPlaceTile.publish(pos3D)

        return layer
    }
}
