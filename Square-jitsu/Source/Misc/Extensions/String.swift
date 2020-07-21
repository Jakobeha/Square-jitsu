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

    /// Example: "fooBarBaz" => "Foo bar baz"
    var camelCaseToSentenceCase: String {
        var words: [String] = []

        var remaining = self
        while let nextSplitIndex = remaining.firstIndex(where: { character in character.isUppercase }) {
            let nextWordRange = ..<nextSplitIndex
            let nextWord = remaining[nextWordRange]
            words.append(String(nextWord))
            remaining.removeSubrange(nextWordRange)
            if !remaining.isEmpty {
                let firstCharacterRange = ..<remaining.index(after: remaining.startIndex)
                remaining.modify(range: firstCharacterRange) { firstCharacter in
                    firstCharacter.localizedLowercase
                }
            }
        }
        words.append(remaining)

        words[0] = words[0].localizedCapitalized

        return words.joined(separator: " ")
    }

    func leftPadding(toLength newLength: Int, withPad character: Character) -> String {
        String(repeatElement(character, count: newLength - self.count)) + self
    }

    func strip(prefix: String) -> Substring? {
        starts(with: prefix) ? self[index(startIndex, offsetBy: prefix.count)...] : nil
    }

    mutating func modify<R: RangeExpression, C: Collection>(range: R, with transformer: (Substring) throws -> C) rethrows where R.Bound == Index, C.Element == Element {
        replaceSubrange(range, with: try transformer(self[range]))
    }
}
