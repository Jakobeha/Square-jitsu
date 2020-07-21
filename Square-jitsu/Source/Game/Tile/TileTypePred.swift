//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// "Predicate" as in this may be generically constructed to contain all tiles e.g. of a particular big type or layer,
/// where a TileTypeSet must specify all of the specific types
struct TileTypePred: Codable {
    static let all: TileTypePred = TileTypePred(containsAll: true)
    static let none: TileTypePred = TileTypePred(containsAll: false)

    var includedExceptExcluded: TileTypePred1Way
    var excluded: TileTypePred1Way

    var containsAll: Bool {
        includedExceptExcluded.containsAll && excluded.containsNone
    }

    init() {
        self.init(TileTypePred1Way([]))
    }

    init(_ containedLayers: Set<TileLayer>) {
        self.init(TileTypePred1Way([], containedLayers))
    }

    init(_ containedBigTypes: Set<TileBigType>, _ containedLayers: Set<TileLayer> = []) {
        self.init(TileTypePred1Way([], containedBigTypes, containedLayers))
    }

    init(_ containedTypes: Set<TileType> = [], _ containedBigTypes: Set<TileBigType> = [], _ containedLayers: Set<TileLayer> = [], containsAll: Bool = false) {
        self.init(TileTypePred1Way(containedTypes, containedBigTypes, containedLayers, containsAll: containsAll))
    }

    init(_ included: TileTypePred1Way) {
        includedExceptExcluded = included
        excluded = TileTypePred1Way.none
    }

    init(included: TileTypePred1Way, excluded: TileTypePred1Way) {
        includedExceptExcluded = included
        self.excluded = excluded
    }

    func contains(_ type: TileType) -> Bool {
        includedExceptExcluded.contains(type) && !excluded.contains(type)
    }

    func contains<OtherCollection: Collection>(anyOf types: OtherCollection) -> Bool where OtherCollection.Element == TileType {
        types.contains(where: contains)
    }
}
