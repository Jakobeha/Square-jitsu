//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct CornerSet: OptionSet, Equatable, Hashable, CaseIterable {
    static let east: CornerSet = CornerSet(rawValue: 1 << 0)
    static let northEast: CornerSet = CornerSet(rawValue: 1 << 1)
    static let north: CornerSet = CornerSet(rawValue: 1 << 2)
    static let northWest: CornerSet = CornerSet(rawValue: 1 << 3)
    static let west: CornerSet = CornerSet(rawValue: 1 << 4)
    static let southWest: CornerSet = CornerSet(rawValue: 1 << 5)
    static let south: CornerSet = CornerSet(rawValue: 1 << 6)
    static let southEast: CornerSet = CornerSet(rawValue: 1 << 7)

    static let allCases: [CornerSet] = ((0 as UInt8)...(255 as UInt8)).map { CornerSet(rawValue: $0) }

    let rawValue: UInt8

    var toBitString: String {
        String(rawValue, radix: 2).leftPadding(toLength: 8, withPad: "0")
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    init(_ denseCornerMap: DenseEnumMap<Corner, Bool>) {
        var this: CornerSet = []
        for corner in Corner.allCases {
            if denseCornerMap[corner] {
                this.formUnion(corner.toSet)
            }
        }
        self.init(rawValue: this.rawValue)
    }
}
