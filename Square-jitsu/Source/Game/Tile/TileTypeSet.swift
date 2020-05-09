//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeSet {
    private var deconstructedTypeMap: [TileBigType:Set<TileSmallType>] = [:]
    private var layers: TileLayerSet = []

    init() {}

    func contains(type: TileType) -> Bool {
        deconstructedTypeMap[type.bigType]?.contains(type.smallType) ?? false
    }

    func contains(bigType: TileBigType) -> Bool {
        deconstructedTypeMap[bigType] != nil
    }

    func contains(layer: TileLayer) -> Bool {
        layers.contains(layer.toSet)
    }

    func smallTypesFor(bigType: TileBigType) -> Set<TileSmallType> {
        deconstructedTypeMap[bigType] ?? []
    }

    mutating func insert(_ type: TileType) {
        var typesForBigType = deconstructedTypeMap.getOrInsert(type.bigType) { [] }
        typesForBigType.insert(type.smallType)
        deconstructedTypeMap[type.bigType] = typesForBigType

        layers.insert(type.bigType.layer.toSet)
    }

    mutating func removeAll() {
        deconstructedTypeMap.removeAll()
        layers = []
    }
}
