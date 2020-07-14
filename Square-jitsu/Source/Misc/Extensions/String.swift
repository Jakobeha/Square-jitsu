//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension String {
    static var defaultTruncatedMaxLength: Int = 16

    static func encodeTuple(items: [String]) -> String {
        "(\(items.joined(separator: ",")))"
    }

    static func decodeTuple(from string: String) -> [Substring]? {
        if string.hasPrefix("(") && string.hasSuffix(")") {
            let contentString = string[string.index(after: string.startIndex)..<string.index(before: string.endIndex)]
            let contentItems = contentString.split(separator: ",")
            return contentItems
        } else {
            return nil
        }
    }

    /// If the string is longer than a certain length (`String.defaultTruncatedMaxLength`),
    /// it will be truncated to the maximum length and '...' (the literal) will be added afterwards
    var truncatedFancy: String {
        getTruncatedFancyTo(maxLength: String.defaultTruncatedMaxLength)
    }

    /// If the string is longer than the maximum length,
    /// it will be truncated to the maximum length and '...' (the literal) will be added afterwards
    func getTruncatedFancyTo(maxLength: Int) -> String {
        count <= maxLength ? self : "\(self[..<index(startIndex, offsetBy: maxLength)])..."
    }

    func leftPadding(toLength newLength: Int, withPad character: Character) -> String {
        String(repeatElement(character, count: newLength - self.count)) + self
    }

    func strip(prefix: String) -> Substring? {
        starts(with: prefix) ? self[index(startIndex, offsetBy: prefix.count)...] : nil
    }
}
