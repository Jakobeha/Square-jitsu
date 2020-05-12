//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeSet {
    private var deconstructedTypeMap: [TileBigType:Set<TileSmallType>] = [:]
    private var typesPerLayer: [TileLayer:Set<TileType>] = [:]

    var containsSolid: Bool {
        contains(layer: TileLayer.solid) || contains(layer: TileLayer.iceSolid)
    }

    init() {}

    func contains(type: TileType) -> Bool {
        deconstructedTypeMap[type.bigType]?.contains(type.smallType) ?? false
    }

    func contains(bigType: TileBigType) -> Bool {
        deconstructedTypeMap[bigType] != nil
    }

    func contains(layer: TileLayer) -> Bool {
        typesPerLayer[layer] != nil
    }

    subscript(bigType: TileBigType) -> Set<TileSmallType> {
        deconstructedTypeMap[bigType] ?? []
    }

    subscript(layer: TileLayer) -> Set<TileType> {
        typesPerLayer[layer] ?? []
    }

    mutating func insert(_ type: TileType) {
        var typesForBigType = deconstructedTypeMap.getOrInsert(type.bigType) { [] }
        typesForBigType.insert(type.smallType)
        deconstructedTypeMap[type.bigType] = typesForBigType

        typesPerLayer.append(key: type.bigType.layer, type)
    }

    mutating func removeAll() {
        deconstructedTypeMap.removeAll()
        typesPerLayer.removeAll()
    }
}
