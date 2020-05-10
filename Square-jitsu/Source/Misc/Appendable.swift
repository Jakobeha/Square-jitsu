//
// Created by Jakob Hain on 5/9/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol Appendable: Sequence, ExpressibleByArrayLiteral {
    mutating func appendOrInsert(_ element: Element)
}

extension Array: Appendable {
    mutating func appendOrInsert(_ element: Element) {
        append(element)
    }
}

extension Set: Appendable {
    mutating func appendOrInsert(_ element: Element) {
        insert(element)
    }
}
