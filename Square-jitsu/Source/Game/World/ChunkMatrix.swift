//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkMatrix<Value: HasDefault> {
    private var backing: [[[Value]]]

    init() {
        backing = [[[Value]]](repeating: [[Value]](repeating: [Value](repeating: Value.defaultValue, count: Chunk.numLayers), count: Chunk.widthHeight), count: Chunk.widthHeight)
    }

    subscript(_ pos: ChunkTilePos) -> [Value] {
        backing[pos.x][pos.y]
    }

    /// Returns the layer the item was inserted at
    mutating func insert(_ item: Value, at pos: ChunkTilePos) -> Int {
        let layer = getNextFreeLayerAt(pos: pos) ?? {
            fatalError("can't place tile because this position is occupied")
        }()
        backing[pos.x][pos.y][layer] = item
        return layer
    }

    mutating func removeAll(at pos: ChunkTilePos) {
        // Move later tiles down, so the last layers are the empty ones
        for layer in 0..<Chunk.numLayers {
            backing[pos.x][pos.y][layer] = Value.defaultValue
        }
    }

    mutating func remove(at pos: ChunkTilePos, layer: Int) {
        let valuesAtPos = backing[pos.x][pos.y]
        // Move later tiles down, so the last layers are the empty ones
        for nextLayer in layer..<(Chunk.numLayers - 1) {
            backing[pos.x][pos.y][nextLayer] = valuesAtPos[nextLayer + 1]
        }
        backing[pos.x][pos.y][Chunk.numLayers - 1] = Value.defaultValue
    }

    func getNextFreeLayerAt(pos: ChunkTilePos) -> Int? {
        let valuesAtPos = backing[pos.x][pos.y]
        var guess = 0
        while (!valuesAtPos[guess].isDefault) {
            guess += 1
            if (guess == valuesAtPos.count) {
                return nil
            }
        }
        return guess
    }

    func hasFreeLayerAt(pos: ChunkTilePos) -> Bool {
        getNextFreeLayerAt(pos: pos) != nil
    }
}
