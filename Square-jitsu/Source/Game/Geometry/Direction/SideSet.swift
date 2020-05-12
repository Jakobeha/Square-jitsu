//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct SideSet: OptionSet, Equatable, Hashable, CaseIterable {
    static let east: SideSet = SideSet(rawValue: 1 << 0)
    static let north: SideSet = SideSet(rawValue: 1 << 1)
    static let west: SideSet = SideSet(rawValue: 1 << 2)
    static let south: SideSet = SideSet(rawValue: 1 << 3)

    static let all: SideSet = [.east, .north, .west, .south]

    static let allCases: [SideSet] = ((0 as UInt8)...(15 as UInt8)).map { SideSet(rawValue: $0) }

    let rawValue: UInt8

    var hasHorizontal: Bool {
        contains(SideSet.east) || contains(SideSet.west)
    }

    var hasVertical: Bool {
        contains(SideSet.north) || contains(SideSet.south)
    }

    var toBitString: String {
        String(rawValue, radix: 2).leftPadding(toLength: 4, withPad: "0")
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    init(_ denseSideMap: DenseEnumMap<Side, Bool>) {
        var this: SideSet = []
        for side in Side.allCases {
            if denseSideMap[side] {
                this.formUnion(side.toSet)
            }
        }
        self.init(rawValue: this.rawValue)
    }
}
