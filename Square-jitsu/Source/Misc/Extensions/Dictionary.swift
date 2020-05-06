//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Dictionary {
    func mapValues<Value2>(_ transform: (Value) throws -> Value2) rethrows -> [Key:Value2] {
        [Key:Value2](uniqueKeysWithValues: try map { (key, value) in (key, try transform(value)) })
    }

    mutating func getOrInsert(_ key: Key, getDefault: () throws -> Value) rethrows -> Value {
        if (self[key] == nil) {
            self[key] = try getDefault()
        }
        return self[key]!
    }
}
