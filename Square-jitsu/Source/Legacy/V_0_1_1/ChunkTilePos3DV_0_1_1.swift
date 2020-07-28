//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct ChunkTilePos3DV_0_1_1: Equatable, Comparable, Hashable, CaseIterable, LosslessStringConvertible, Codable, JSONCodable {
    static let zero: ChunkTilePos3DV_0_1_1 = ChunkTilePos3DV_0_1_1(pos: ChunkTilePos.zero, layer: 0)
    
    /// Natural order is the same as that in `allCases`
    static func <(lhs: ChunkTilePos3DV_0_1_1, rhs: ChunkTilePos3DV_0_1_1) -> Bool {
        lhs.order < rhs.order
    }

    let pos: ChunkTilePos
    let layer: Int

    var order: Int {
        layer + (pos.order * Chunk.numLayers)
    }

    static let allCases: [ChunkTilePos3DV_0_1_1] = {
        ChunkTilePos.allCases.flatMap { pos in
            (0..<ChunkV_0_1_1.numLayers).map { layer in
                ChunkTilePos3DV_0_1_1(pos: pos, layer: layer)
            }
        }
    }()

    init(_ upgraded: ChunkTilePos3D) {
        self.init(pos: upgraded.pos, layer: upgraded.layer)
    }

    var upgraded: ChunkTilePos3D {
        ChunkTilePos3D(pos: pos, layer: min(layer, Chunk.numLayers - 1))
    }

    init(pos: ChunkTilePos, layer: Int) {
        self.pos = pos
        self.layer = layer
    }

    //region encoding / decoding between string and json
    var description: String { String.encodeTuple(items: [String(pos.x), String(pos.y), String(layer)]) }

    init?(_ description: String) {
        if let descItems = String.decodeTuple(from: description),
           descItems.count == 3,
           let posX = Int(descItems[0]),
           let posY = Int(descItems[1]),
           let layer = Int(descItems[2]) {
            self.init(pos: ChunkTilePos(x: posX, y: posY), layer: layer)
        } else {
            return nil
        }
    }

    func encodeToJson() throws -> JSON {
        JSON(self.description)
    }

    init(from json: JSON) throws {
        let jsonString = try json.toString()
        if let this = ChunkTilePos3DV_0_1_1(jsonString) {
            self = this
        } else {
            throw DecodeSettingError.badFormat(expectedDescription: "chunk tile position")
        }
    }
    //endregion
}
