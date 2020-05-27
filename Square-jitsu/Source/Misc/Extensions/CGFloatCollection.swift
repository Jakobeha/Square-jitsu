//
// Created by Jakob Hain on 5/25/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension Collection where Element == CGFloat {
    func sum() -> CGFloat {
        reduce(0) { $0 + $1 }
    }

    func average() -> CGFloat? {
        isEmpty ? 0 : sum() / CGFloat(count)
    }
}
