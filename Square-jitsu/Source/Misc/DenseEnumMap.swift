//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Dense enum or enum set map
struct DenseEnumMap<Key: CaseIterable & RawRepresentable, Value>: Sequence where Key.RawValue: Integral {
    typealias Iterator = Array<Element>.Iterator

    typealias Element = (key: Key, value: Value)

    private var backing: [Value]

    var toList: [Element] {
        Key.allCases.map { key in (key: key, value: self[key] ) }
    }

    var values: [Value] { backing }

    subscript(key: Key) -> Value {
        get {
            backing[key.rawValue.toInt]
        }
        set {
            backing[key.rawValue.toInt] = newValue
        }
    }

    init(valueGetter: (Key) throws -> Value) rethrows {
        backing = try Key.allCases.map(valueGetter)
    }

    func mapValues<Value2>(transform: (Value) throws -> Value2) rethrows -> DenseEnumMap<Key, Value2> {
        try DenseEnumMap<Key, Value2> { key in try transform(self[key]) }
    }

    func makeIterator() -> Iterator { toList.makeIterator() }
}

extension DenseEnumMap: ExpressibleByDictionaryLiteral where Value: HasDefault {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for (key, value) in elements {
            self[key] = value
        }
    }

    private init() {
        self.init { _ in Value.defaultValue }
    }
}

extension DenseEnumMap where Value: Appendable {
    var allElements: [Value.Element] {
        values.flatMap { $0 }
    }

    mutating func append(key: Key, _ element: Value.Element) {
        self[key].appendOrInsert(element)
    }
}