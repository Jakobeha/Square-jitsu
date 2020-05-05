//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkMatrix<Value> {
    private let defaultValue: Value
    private var backing: [[[Value]]]

    init(defaultValue: Value) {
        self.defaultValue = defaultValue
        backing = [[[Value]]](repeating: [[Value]](repeating: [Value](repeating: defaultValue, count: Chunk.numLayers), count: Chunk.widthHeight), count: Chunk.widthHeight)
    }

    subscript(_ pos: ChunkTilePos) -> [Value] {
        get {
            backing[pos.x][pos.y]
        }
        set {
            backing[pos.x][pos.y] = newValue
        }
    }

    mutating func removeAll(at pos: ChunkTilePos) {
        // Move later tiles down, so the last layers are the empty ones
        for layer in 0..<Chunk.numLayers {
            backing[pos.x][pos.y][layer] = defaultValue
        }
    }

    mutating func remove(at pos: ChunkTilePos, layer: Int) {
        let valuesAtPos = backing[pos.x][pos.y]
        // Move later tiles down, so the last layers are the empty ones
        for nextLayer in layer..<(Chunk.numLayers - 1) {
            backing[pos.x][pos.y][nextLayer] = valuesAtPos[nextLayer + 1]
        }
        backing[pos.x][pos.y][Chunk.numLayers - 1] = defaultValue
    }
}
