//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol Integral {
    var toInt: Int { get }
}

extension Int: Integral {
    var toInt: Int { self }
}

extension UInt8: Integral {
    var toInt: Int { Int(self) }
}
