//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Automatic implementation of `CompactCodable` for value types (without pointers).
/// Based off https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data
protocol CompactCodableByValue: CompactCodable {}

extension CompactCodableByValue {
    mutating func decode(from data: Data) {
        assert(data.count == MemoryLayout.size(ofValue: self))
        _ = withUnsafeMutableBytes(of: &self) { selfPtr in data.copyBytes(to: selfPtr) }
    }

    var toData: Data {
        withUnsafeBytes(of: self) { selfPtr in Data(selfPtr) }
    }

    static var sizeAsData: Int { MemoryLayout<Self>.size }
}