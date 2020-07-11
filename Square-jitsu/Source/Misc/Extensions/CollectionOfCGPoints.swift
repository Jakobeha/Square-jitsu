//
// Created by Jakob Hain on 5/25/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension Collection where Element == CGPoint {
    func sum() -> CGPoint {
        reduce(CGPoint.zero) { $0 + $1 }
    }

    func average() -> CGPoint? {
        isEmpty ? CGPoint.zero : sum() / CGFloat(count)
    }
}
