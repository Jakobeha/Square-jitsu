//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeMap<Value> {
    private var backing: [TileBigType:[TileSmallType:Value]]

    init() {
        self.init([:])
    }

    init(_ backing: [TileBigType: [TileSmallType: Value]]) {
        self.backing = backing
    }

    subscript(type: TileType) -> Value? {
        get {
            backing[type.bigType]?[type.smallType]
        }
        set {
            // inserts an empty map if setting empty to nil but who cares?
            if (backing[type.bigType] == nil) {
                backing[type.bigType] = [:]
            }
            backing[type.bigType]![type.smallType] = newValue
        }
    }
}
