//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class OptionalSetting<Wrapped>: SerialSetting {
    private let wrappedSetting: SerialSetting
    private var isNone: Bool = true

    init(_ wrappedSetting: SerialSetting) {
        self.wrappedSetting = wrappedSetting
    }

    func decodeWellFormed(from json: JSON) throws {
        if json.isNull {
            isNone = true
        } else {
            isNone = false
            try wrappedSetting.decodeWellFormed(from: json)
        }
    }

    func encodeWellFormed() throws -> JSON {
        isNone ? JSON.null : try wrappedSetting.encodeWellFormed()
    }

    func validate() throws {
        if !isNone {
            try wrappedSetting.validate()
        }
    }

    func decodeDynamically<T>() -> T {
        isNone ? (Optional<Any>.none as! T) : wrappedSetting.decodeDynamically()
    }

    func encodeDynamically(_ optional: Wrapped?) {
        if let wrapped = optional {
            isNone = false
            (wrapped as! DynamicSettingCodable).encodeDynamically(to: wrappedSetting)
        } else {
            isNone = true
        }
    }
}

extension Optional: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! OptionalSetting<Wrapped>).encodeDynamically(self)
    }
}