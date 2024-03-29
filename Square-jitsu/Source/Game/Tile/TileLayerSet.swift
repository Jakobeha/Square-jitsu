//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TileLayerSet: OptionSet {
    static let air: TileLayerSet = TileLayerSet(rawValue: 1 << 0)

    static let background: TileLayerSet = TileLayerSet(rawValue: 1 << 1)
    static let backgroundDirectionBoost: TileLayerSet = TileLayerSet(rawValue: 1 << 2)

    static let solid: TileLayerSet = TileLayerSet(rawValue: 1 << 3)
    static let iceSolid: TileLayerSet = TileLayerSet(rawValue: 1 << 4)

    static let edge: TileLayerSet = TileLayerSet(rawValue: 1 << 5)

    static let free: TileLayerSet = TileLayerSet(rawValue: 1 << 6)

    static let collectible: TileLayerSet = TileLayerSet(rawValue: 1 << 7)

    static let entity: TileLayerSet = TileLayerSet(rawValue: 1 << 8)

    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    init<TileLayerCollection: Collection>(_ layers: TileLayerCollection) where TileLayerCollection.Element == TileLayer {
        self = []
        for layer in layers {
            formUnion(layer.toSet)
        }
    }
}
