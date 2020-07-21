//
// Created by Jakob Hain on 7/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension BinaryInteger {
    var sign: NumericSign {
        NumericSign(rawValue: Int(signum()))!
    }
}
