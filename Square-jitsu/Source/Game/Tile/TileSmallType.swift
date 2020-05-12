//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileSmallType: Equatable, Hashable {
    var value: UInt8

    var isOn: Bool {
        get {
            (value & 1) == 1
        }
        set {
            if newValue {
                value |= 1
            } else {
                value &= ~1
            }
        }
    }

    init(_ value: UInt8) {
        self.value = value
    }
}
