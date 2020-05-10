//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileSmallType: Equatable, Hashable {
    let value: UInt8

    var isOn: Bool {
        (value & 1) == 1
    }

    init(_ value: UInt8) {
        self.value = value
    }

    func with(isOn: Bool) -> TileSmallType {
        TileSmallType(isOn ? value | 1 : value & ~1)
    }
}
