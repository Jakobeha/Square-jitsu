//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class NeverSetting: SerialSetting {
    init() {}

    func decodeWellFormed(from json: JSON) throws {
        throw DecodeSettingError.cantDecodeNever
    }

    func encodeWellFormed() throws -> JSON {
        throw DecodeSettingError.cantEncodeNever
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T {
        fatalError("can't decode never")
    }
}