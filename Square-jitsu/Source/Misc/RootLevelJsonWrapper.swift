//
// Created by Jakob Hain on 6/1/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Wraps a Codable which encodes / decodes into a primitive
/// so it can be encoded / decoded by `JSONEncoder` / `JSONDecoder` without throwing an error
fileprivate struct RootLevelJsonWrapper<Value> {
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

extension RootLevelJsonWrapper: Decodable where Value: Decodable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decode(Value.self)
    }
}

extension RootLevelJsonWrapper: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(value)
    }
}

extension JSONDecoder {
    /// Decodes a wrapped value, so it can decode root-level primitives encoded by `encodeWrapped`
    func decodeWrapped<Value: Decodable>(_ type: Value.Type, from data: Data) throws -> Value {
        try decode(RootLevelJsonWrapper<Value>.self, from: data).value
    }
}

extension JSONEncoder {
    /// Encodes a wrapped value, so it can encode root-level primitives decodable by `decodeWrapped`
    func encodeWrapped<Value: Encodable>(_ value: Value) throws -> Data {
        try encode(RootLevelJsonWrapper(value))
    }
}