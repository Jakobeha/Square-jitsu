//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct WorldFileSyncError: Error, CustomStringConvertible {
    let action: String
    let error: Error

    var description: String {
        "I/O error when \(action) - \(error)"
    }
}
