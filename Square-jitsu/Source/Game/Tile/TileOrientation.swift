//
// Created by Jakob Hain on 5/9/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct TileOrientation: Equatable, Hashable, LosslessStringConvertible {
    static let none = TileOrientation(rawValue: 0)

    var rawValue: UInt8

    var toSide: Side {
        Side(rawValue: Int(rawValue))!
    }

    var toSideSet: SideSet {
        SideSet(rawValue: rawValue)
    }

    init(side: Side) {
        self.rawValue = UInt8(side.rawValue)
    }

    init(sideSet: SideSet) {
        self.init(rawValue: sideSet.rawValue)
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    init?(_ description: String) {
        if let value = UInt8(description) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }

    var description: String { rawValue.description }
}
