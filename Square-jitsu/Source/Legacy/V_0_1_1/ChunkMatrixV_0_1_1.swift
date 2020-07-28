//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkMatrixV_0_1_1<Value: HasDefault> {
    private var backing: [[[Value]]]

    init() {
        backing = [[[Value]]](repeating: [[Value]](repeating: [Value](repeating: Value.defaultValue, count: ChunkV_0_1_1.numLayers), count: Chunk.widthHeight), count: Chunk.widthHeight)
    }

    subscript(_ pos: ChunkTilePos) -> [Value] {
        get {
            backing[pos.x][pos.y]
        }
        set {
            backing[pos.x][pos.y] = newValue
        }
    }

    subscript(_ pos3D: ChunkTilePos3DV_0_1_1) -> Value {
        get {
            self[pos3D.pos][pos3D.layer]
        }
        set {
            self[pos3D.pos][pos3D.layer] = newValue
        }
    }

    /// - Returns: The layer where the item was inserted
    mutating func insert(_ item: Value, at pos: ChunkTilePos) -> Int {
        let layer = getNextFreeLayerAt(pos: pos) ?? {
            fatalError("can't place tile because this position is occupied")
        }()
        backing[pos.x][pos.y][layer] = item
        return layer
    }

    mutating func removeAll(at pos: ChunkTilePos) {
        // Move later tiles down, so the last layers are the empty ones
        for layer in 0..<ChunkV_0_1_1.numLayers {
            backing[pos.x][pos.y][layer] = Value.defaultValue
        }
    }

    mutating func remove(at pos3D: ChunkTilePos3DV_0_1_1) {
        let pos = pos3D.pos
        backing[pos.x][pos.y][pos3D.layer] = Value.defaultValue
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

extension ChunkMatrixV_0_1_1: CompactCodable where Value: CompactCodable {
    mutating func decode(from data: Data) {
        assert(data.count == ChunkTilePos3DV_0_1_1.allCases.count * MemoryLayout<Value>.size)
        for (index, pos3D) in ChunkTilePos3DV_0_1_1.allCases.enumerated() {
            let itemByteOffset = index * MemoryLayout<Value>.size
            let itemByteRange = itemByteOffset..<(itemByteOffset + MemoryLayout<Value>.size)
            let itemData = data[itemByteRange]
            self[pos3D].decode(from: itemData)
        }
    }

    var toData: Data {
        var data = Data(capacity: Self.sizeAsData)
        for pos3D in ChunkTilePos3DV_0_1_1.allCases {
            let item = self[pos3D]
            let itemData = item.toData
            data.append(itemData)
        }
        return data
    }

    static var sizeAsData: Int {
        ChunkTilePos3DV_0_1_1.allCases.count * MemoryLayout<Value>.size
    }
}