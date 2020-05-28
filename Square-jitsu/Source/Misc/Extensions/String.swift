//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension String {
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

    func leftPadding(toLength newLength: Int, withPad character: Character) -> String {
        String(repeatElement(character, count: newLength - self.count)) + self
    }

    func strip(prefix: String) -> Substring? {
        starts(with: prefix) ? self[index(startIndex, offsetBy: prefix.count)...] : nil
    }
}
