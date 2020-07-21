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
        private let end: Int
        private let step: Int

        init(start: Int, end: Int) {
            current = start
            self.end = end
            step = start <= end ? 1 : -1
        }

        mutating func next() -> Element? {
            if current == end + step {
                return nil
            } else {
                let result = current
                current += step
                return result
            }
        }
    }

    let start: Int
    let end: Int

    init(_ start: Int, _ end: Int) {
        self.start = start
        self.end = end
    }

    func makeIterator() -> Iterator {
        Iterator(start: start, end: end)
    }
}
