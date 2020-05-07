//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Closed range which can go forward or backward, unlike ClosedRange<Int>
struct FBRange: Sequence {
    struct Iterator: IteratorProtocol {
        typealias Element = Int

        private var current: Int
        private let rhs: Int
        private let step: Int

        init(lhs: Int, rhs: Int) {
            current = lhs
            self.rhs = rhs
            step = lhs <= rhs ? 1 : -1
        }

        mutating func next() -> Element? {
            if current == rhs + step {
                return nil
            } else {
                let result = current
                current += step
                return result
            }
        }
    }

    let lhs: Int
    let rhs: Int

    init(_ lhs: Int, _ rhs: Int) {
        self.lhs = lhs
        self.rhs = rhs
    }

    func makeIterator() -> Iterator {
        Iterator(lhs: lhs, rhs: rhs)
    }
}
