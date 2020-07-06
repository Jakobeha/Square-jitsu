//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeSet {
    private var smallTypesPerBigType: [TileBigType:Set<TileSmallType>] = [:]
    private var orientationsPerBigType: [TileBigType:Set<TileOrientation>] = [:]
    private var typesPerLayer: [TileLayer:Set<TileType>] = [:]

    var containsBackground: Bool {
        contains(layer: .background)
    }

    var containsSolid: Bool {
        contains(layer: .solid) || contains(layer: .iceSolid) || contains(bigType: .solidEdge)
    }

    init() {}

    func contains(type: TileType) -> Bool {
        smallTypesPerBigType[type.bigType]?.contains(type.smallType) ?? false &&
        orientationsPerBigType[type.bigType]!.contains(type.orientation)
    }

    func contains(bigType: TileBigType) -> Bool {
        smallTypesPerBigType[bigType] != nil
    }

    func contains(layer: TileLayer) -> Bool {
        typesPerLayer[layer] != nil
    }

    func getSmallTypesWith(bigType: TileBigType) -> Set<TileSmallType> {
        smallTypesPerBigType[bigType] ?? []
    }

    func getOrientationsWith(bigType: TileBigType) -> Set<TileOrientation> {
        orientationsPerBigType[bigType] ?? []
    }

    subscript(layer: TileLayer) -> Set<TileType> {
        typesPerLayer[layer] ?? []
    }

    mutating func insert(_ type: TileType) {
        smallTypesPerBigType.append(key: type.bigType, type.smallType)
        orientationsPerBigType.append(key: type.bigType, type.orientation)
        typesPerLayer.append(key: type.bigType.layer, type)
    }

    mutating func removeAll() {
        smallTypesPerBigType.removeAll()
        orientationsPerBigType.removeAll()
        typesPerLayer.removeAll()
    }
}
