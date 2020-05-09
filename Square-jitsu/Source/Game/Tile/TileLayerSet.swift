//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TileLayerSet: OptionSet {
    static let air: TileLayerSet = TileLayerSet(rawValue: 1 << 0)
    static let background: TileLayerSet = TileLayerSet(rawValue: 1 << 1)
    static let solid: TileLayerSet = TileLayerSet(rawValue: 1 << 2)
    static let entity: TileLayerSet = TileLayerSet(rawValue: 1 << 3)

    let rawValue: UInt32
}
