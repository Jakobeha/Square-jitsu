//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - (size / 2), size: size)
    }

    func insetBy(sideLength: CGFloat) -> CGRect {
        insetBy(dx: sideLength, dy: sideLength)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }

    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    var topLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }

    var topRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
}
