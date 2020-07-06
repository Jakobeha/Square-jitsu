//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct SideSet: MonoidOptionSet, Equatable, Hashable, CaseIterable {
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

    var asActualSet: Set<Side> {
        get { Set(Side.allCases.filter { side in self.contains(side.toSet) }) }
        set { self = SideSet(newValue) }
    }

    var count: Int {
        Side.allCases.filter { side in self.contains(side.toSet) }.count
    }

    var first: Side? {
        Side.allCases.first { side in self.contains(side.toSet) }
    }
    
    var inverted: SideSet {
        SideSet.all.subtracting(self)
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

    init<SideCollection: Collection>(_ sides: SideCollection) where SideCollection.Element == Side {
        self = sides.map { side in side.toSet }.reduce()
    }

    func rotated90Degrees(numTimes: Int) -> SideSet {
        SideSet(asActualSet.map { side in side.rotated90Degrees(numTimes: numTimes)})
    }

    /// Example: Given 0, will return this set.
    /// Given 1, will return this set unioned with itself rotated counter clockwise once.
    /// Given 2, will return this set unioned with itself rotated counter clockwise once and unioned with itself rotated twice.
    /// Given a negative number, behaves the same as given the absolute value except the rotations are clockwise
    func unionRotated90DegreesUpTo(numTimes: Int) -> SideSet {
        var result = self
        if numTimes > 0 {
            for rotationCount in 0..<(numTimes % 4) {
                result.formUnion(rotated90Degrees(numTimes: rotationCount))
            }
        } else {
            for rotationCount in 0..<(-numTimes % 4) {
                result.formUnion(rotated90Degrees(numTimes: -rotationCount))
            }
        }
        return result
    }
}
