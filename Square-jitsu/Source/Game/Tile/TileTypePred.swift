//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// "Predicate" as in this may be generically constructed to contain all tiles e.g. of a particular big type or layer,
/// where a TileTypeSet must specify all of the specific types
struct TileTypePred {
    static let all: TileTypePred = TileTypePred(containsAll: true)

    private let containedTypes: Set<TileType>
    private let containedBigTypes: Set<TileBigType>
    private let containedLayers: Set<TileLayer>
    private let containsAll: Bool

    init() {
        self.init([])
    }

    init(_ containedLayers: Set<TileLayer>) {
        self.init([], containedLayers)
    }

    init(_ containedBigTypes: Set<TileBigType>, _ containedLayers: Set<TileLayer> = []) {
        self.init([], containedBigTypes, containedLayers)
    }

    init(_ containedTypes: Set<TileType>, _ containedBigTypes: Set<TileBigType> = [], _ containedLayers: Set<TileLayer> = []) {
        self.init(containedTypes, containedBigTypes, containedLayers, containsAll: false)
    }

    private init(_ containedTypes: Set<TileType> = [], _ containedBigTypes: Set<TileBigType> = [], _ containedLayers: Set<TileLayer> = [], containsAll: Bool = false) {
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
}
