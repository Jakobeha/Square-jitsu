//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// A data which is decoded when already initialized
protocol AliveDecodable {
    func decode(from decoder: Decoder) throws
}
