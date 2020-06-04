//
// Created by Jakob Hain on 6/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Forwards all implementations of SerialSetting to a lazily-generated setting.
/// Used in recursive settings
/// (e.g. a struct setting which references itself or an outer struct / union setting)
class DeferredSetting: SerialSetting {
    private let generateWrappedSetting: () -> SerialSetting

    private var wrapped: SerialSetting?

    init(_ generateWrappedSetting: @escaping () -> SerialSetting) {
        self.generateWrappedSetting = generateWrappedSetting
    }

    func decodeWellFormed(from json: JSON) throws {
        try forceGetWrapped().decodeWellFormed(from: json)
    }

    func encodeWellFormed() throws -> JSON {
        try forceGetWrapped().encodeWellFormed()
    }

    func validate() throws {
        try wrapped?.validate()
    }

    func decodeDynamically<T>() -> T {
        forceGetWrapped().decodeDynamically()
    }

    private func forceGetWrapped() -> SerialSetting {
        if wrapped == nil {
            wrapped = generateWrappedSetting()
        }
        return wrapped!
    }
}
