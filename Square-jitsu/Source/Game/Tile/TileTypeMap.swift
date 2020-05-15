//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileTypeMap<Value> {
    private var _backing: [TileBigType:[Value?]]

    var backing: [TileBigType:[Value?]] { _backing }

    init() {
        self.init([:])
    }

    init(_ backing: [TileBigType:[Value?]]) {
        self._backing = backing
    }

    subscript(type: TileType) -> Value? {
        get {
            _backing[type.bigType]?.getIfPresent(at: Int(type.smallType.value)) ?? nil
        }
        set {
            // inserts an empty map if setting empty to nil but who cares?
            var valuesAtBigType = _backing[type.bigType] ?? []
            let index = Int(type.smallType.value)
            while (valuesAtBigType.count < index) {
                valuesAtBigType.append(nil)
            }
            if (valuesAtBigType.count == index) {
                valuesAtBigType.append(newValue)
            } else {
                valuesAtBigType[index] = newValue
            }
            _backing[type.bigType] = valuesAtBigType
        }
    }
}
