//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol CompactCodable {
    mutating func decode(from data: Data)

    var toData: Data { get }

    static var sizeAsData: Int { get }
}