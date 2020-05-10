//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Dictionary where Value: Appendable {
    var allElements: [Value.Element] {
        values.flatMap { $0 }
    }

    mutating func append(key: Key, _ element: Value.Element) {
        if self[key] == nil {
            self[key] = []
        }
        self[key]!.appendOrInsert(element)
    }
}
