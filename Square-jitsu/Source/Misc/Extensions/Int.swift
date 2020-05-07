//
// Created by Jakob Hain on 5/6/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Int {
    /// Less than or equal to the floating-point quotient
    ///
    /// x = (x.floorQuotient(dividingBy: y) * y) + x.positiveRemainder(dividingBy: y)
    func floorQuotient(dividingBy divisor: Int) -> Int {
        self < 0 ? ((self + 1) / divisor) - 1 : self / divisor
    }

    /// Guaranteed to be positive
    ///
    /// x = (x.floorQuotient(dividingBy: y) * y) + x.positiveRemainder(dividingBy: y)
    func positiveRemainder(dividingBy divisor: Int) -> Int {
        self < 0 ? ((self + 1) % divisor) + divisor - 1 : self % divisor
    }
}
