//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Closed range with an explicitly defined step.
/// Depending on the step, it will iterate forward or backward,
/// and if the step is in the opposite sign of end - start it will be empty
struct ExplicitStepRange: Sequence {
    struct Iterator: IteratorProtocol {
        typealias Element = Int

        private var current: Int
        private let end: Int
        private let step: Int
        
        private var isPastEnd: Bool {
            switch step.sign {
            case .negative:
                return current < end
            case .zero:
                return false
            case .positive:
                return current > end
            }
        }

        init(start: Int, end: Int, step: Int) {
            current = start
            self.end = end
            self.step = step
        }

        mutating func next() -> Element? {
            if isPastEnd {
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
    let step: Int

    func makeIterator() -> Iterator {
        Iterator(start: start, end: end, step: step)
    }
}
