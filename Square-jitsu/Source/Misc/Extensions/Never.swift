//
// Created by Jakob Hain on 6/1/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Never: Codable {
    public init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "can't decode never"
        ))
    }

    public func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(
            codingPath: encoder.codingPath,
            debugDescription: "can't encode never"
        ))
    }
}
