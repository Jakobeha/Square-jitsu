//
// Created by Jakob Hain on 5/23/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Identical to `LosslessStringConvertible` but doesn't override String(describing:)
protocol LosslessStringConvertibleEnum {
    var description: String { get }

    init?(_ description: String)
}
