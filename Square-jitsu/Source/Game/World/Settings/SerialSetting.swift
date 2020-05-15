//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// A serializer, validator, and inspector for a value
protocol SerialSetting {
    func decodeWellFormed(from json: JSON) throws
    func encodeWellFormed() throws -> JSON

    // Implement validation here, only check well-formedness in decode
    func validate() throws

    func decodeDynamically<T>() -> T
}

extension SerialSetting {
    /// Decode then validate
    func decode(from json: JSON) throws {
        try decodeWellFormed(from: json)
        try validate()
    }

    /// Validate then encode
    func encode() throws -> JSON {
        try validate()
        return try encodeWellFormed()
    }
}