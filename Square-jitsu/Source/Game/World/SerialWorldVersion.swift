//
// Created by Jakob Hain on 6/26/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum SerialWorldVersion: String, Comparable, CaseIterable, Codable {
    case _0_1_0
    case _0_1_1
    case _0_1_2

    static let latest: SerialWorldVersion = ._0_1_2

    // region ordering
    static func <(lhs: SerialWorldVersion, rhs: SerialWorldVersion) -> Bool {
        lhs.order < rhs.order
    }

    private var order: Int {
        SerialWorldVersion.allCases.firstIndex(of: self)!
    }
    // endregion

    // region encoding and decoding
    init?(literal: String) {
        self.init(rawValue: "_\(literal.replacingOccurrences(of: ".", with: "_"))")
    }

    var literal: String {
        rawValue.strip(prefix: "_")!.replacingOccurrences(of: "_", with: ".")
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let this = SerialWorldVersion(literal: try container.decode(String.self)) {
            self = this
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "unsupported version")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(literal)
    }
    // endregion
}
