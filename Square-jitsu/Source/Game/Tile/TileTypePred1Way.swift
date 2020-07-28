//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// "Predicate" as in this may be generically constructed to contain all tiles e.g. of a particular big type or layer,
/// where a TileTypeSet must specify all of the specific types.
/// "Additive" in that you can only add layers, big-types, etc. to this,
/// you can't specify e.g. that all tiles in layer X *except* Y and Z satisfy the predicate
struct TileTypePred1Way: Codable {
    static let all: TileTypePred1Way = TileTypePred1Way(containsAll: true)
    static let none: TileTypePred1Way = TileTypePred1Way(containsAll: false)

    var containedTypes: Set<TileType>
    var containedBigTypes: Set<TileBigType>
    var containedLayers: Set<TileLayer>
    var containsAll: Bool
    
    var containsNone: Bool {
        !containsAll &&
        containedLayers.isEmpty &&
        containedBigTypes.isEmpty &&
        containedTypes.isEmpty
    }

    init() {
        self.init([])
    }

    init(_ containedLayers: Set<TileLayer>) {
        self.init([], containedLayers)
    }

    init(_ containedBigTypes: Set<TileBigType>, _ containedLayers: Set<TileLayer> = []) {
        self.init([], containedBigTypes, containedLayers)
    }

    init(_ containedTypes: Set<TileType> = [], _ containedBigTypes: Set<TileBigType> = [], _ containedLayers: Set<TileLayer> = [], containsAll: Bool = false) {
        self.containedTypes = containedTypes
        self.containedBigTypes = containedBigTypes
        self.containedLayers = containedLayers
        self.containsAll = containsAll
    }

    func contains(_ type: TileType) -> Bool {
        containedTypes.contains(type) ||
        containedBigTypes.contains(type.bigType) ||
        containedLayers.contains(type.bigType.layer) ||
        containsAll
    }

    func contains<OtherCollection: Collection>(anyOf types: OtherCollection) -> Bool where OtherCollection.Element == TileType {
        containedTypes.contains(anyOf: types) ||
        containedBigTypes.contains(anyOf: types.map { $0.bigType }) ||
        containedLayers.contains(anyOf: types.map { $0.bigType.layer }) ||
        containsAll
    }

    mutating func insertSolidTypes() {
        containedLayers.insert(.solid)
        containedLayers.insert(.iceSolid)
        containedBigTypes.insert(.solidEdge)
    }
}
