//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeMap<Value> {
    private var backing: [TileBigType:[Value?]]

    init() {
        self.init([:])
    }

    init(_ backing: [TileBigType:[Value?]]) {
        self.backing = backing
    }

    subscript(type: TileType) -> Value? {
        get {
            backing[type.bigType]?[Int(type.smallType.value)]
        }
        set {
            // inserts an empty map if setting empty to nil but who cares?
            var valuesAtBigType = backing[type.bigType] ?? []
            let index = Int(type.smallType.value)
            while (valuesAtBigType.count < index) {
                valuesAtBigType.append(nil)
            }
            if (valuesAtBigType.count == index) {
                valuesAtBigType.append(newValue)
            } else {
                valuesAtBigType[index] = newValue
            }
            backing[type.bigType] = valuesAtBigType
        }
    }
}
