//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct RelativePos: Equatable, Hashable {
    static let zero: RelativePos = RelativePos(x: 0, y: 0)

    let x: Int
    let y: Int

    var toCgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
