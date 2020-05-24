//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGSize {
    static let zero: CGSize = square(sideLength: 0)
    static let unit: CGSize = square(sideLength: 1)
    static let infinity: CGSize = square(sideLength: CGFloat.infinity)

    static func square(sideLength: CGFloat) -> CGSize {
        CGSize(width: sideLength, height: sideLength)
    }

    static prefix func -(size: CGSize) -> CGSize {
        CGSize(width: -size.width, height: -size.height)
    }

    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func *(lhs: CGSize, scale: CGFloat) -> CGSize {
        CGSize(width: lhs.width * scale, height: lhs.height * scale)
    }

    static func /(lhs: CGSize, scale: CGFloat) -> CGSize {
        CGSize(width: lhs.width / scale, height: lhs.height / scale)
    }

    var aspectRatioYDivX: CGFloat { height / width }

    var toPoint: CGPoint {
        CGPoint(x: width, y: height)
    }
}
