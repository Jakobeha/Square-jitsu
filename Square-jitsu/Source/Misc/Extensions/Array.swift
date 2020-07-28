//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Array {
    func associateWith<Value>(associate: (Element) throws -> Value) rethrows -> [Element : Value] {
        [Element : Value](uniqueKeysWithValues: try map { key in (key, try associate(key)) })
    }

    func getIfPresent(at index: Int) -> Element? {
        (index >= 0 && index < count) ? self[index] : nil
    }

    func indicesWhere(_ predicate: (Element) throws -> Bool) rethrows -> [Int] {
        try enumerated().filter { (_, element) in
            try predicate(element)
        }.map { (index, _) in index }
    }
}