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

    /// Example: "fooBarBaz" => "foo bar baz"
    var camelCaseToSubSentenceCase: String {
        let words = wordsInCamelCase
        return words.joined(separator: " ")
    }

    /// Example: "fooBarBaz" => "Foo bar baz"
    var camelCaseToSentenceCase: String {
        var words = wordsInCamelCase
        words[0] = words[0].localizedCapitalized
        return words.joined(separator: " ")
    }

    /// Example: "fooBarBaz" => ["foo", "bar", "baz"]
    var wordsInCamelCase: [String] {
        var words: [String] = []

        var remaining = self
        while let nextSplitIndex = remaining.firstIndex(where: { character in character.isUppercase }) {
            // Make the first character lowercase, since the resulting words are lowercase
            if !remaining.isEmpty {
                let firstCharacterRange = ..<remaining.index(after: remaining.startIndex)
                remaining.modify(range: firstCharacterRange) { firstCharacter in
                    firstCharacter.localizedLowercase
                }
            }

            // Get the next word and range
            let nextWordRange = ..<nextSplitIndex
            let nextWord = remaining[nextWordRange]

            // Add the next word
            words.append(String(nextWord))

            // Remove the range from remaining
            remaining.removeSubrange(nextWordRange)
        }
        words.append(remaining)

        return words
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
