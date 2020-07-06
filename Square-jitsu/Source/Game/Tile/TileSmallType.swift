//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileSmallType: Equatable, Hashable, LosslessStringConvertible {
    var value: UInt8

    var isOn: Bool {
        get { (value & 1) == 1 }
        set {
            if newValue {
                value |= 1
            } else {
                value &= ~1
            }
        }
    }
    var isClockwise: Bool {
        get { (value & 2) == 2 }
        set {
            if newValue {
                value |= 2
            } else {
                value &= ~2
            }
        }
    }

    init(_ value: UInt8) {
        self.value = value
    }

    init?(_ description: String) {
        if let value = UInt8(description) {
            self.init(value)
        } else {
            return nil
        }
    }

    var description: String { value.description }
}
