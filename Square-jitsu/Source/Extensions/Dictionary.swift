//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func getOrInsert(_ key: Key, getDefault: () throws -> Value) rethrows -> Value {
        if (self[key] == nil) {
            self[key] = try getDefault()
        }
        return self[key]!
    }
}
