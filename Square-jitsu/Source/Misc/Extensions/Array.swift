//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension Array {
    func associateWith<Value>(associate: (Element) throws -> Value) rethrows -> [Element : Value] {
        [Element : Value](uniqueKeysWithValues: try map { key in (key, try associate(key)) })
    }
}
