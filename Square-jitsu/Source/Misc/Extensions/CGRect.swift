//
// Created by Jakob Hain on 5/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
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

    var corners: [CGPoint] {
        [topRight, topLeft, bottomLeft, bottomRight]
    }

    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - (size / 2), size: size)
    }

    /// Multiplies the origin and size
    func scaleCoordsBy(scale: CGFloat) -> CGRect {
        CGRect(origin: origin * scale, size: size * scale)
    }

    func offsetBy(vector: CGPoint) -> CGRect {
        offsetBy(dx: vector.x, dy: vector.y)
    }

    func insetBy(sideLength: CGFloat) -> CGRect {
        insetBy(dx: sideLength, dy: sideLength)
    }

    /// The bounds of this rectangle (as a geometric shape) rotated by angle
    func rotateBoundsBy(_ angle: Angle) -> CGRect {
        let originalQuadrant = (size / 2).toPoint
        let rotatedQuadrant = originalQuadrant.rotateAroundCenter(by: angle)
        let rotatedSize = CGSize(
            width: abs(rotatedQuadrant.x) * 2,
            height: abs(rotatedQuadrant.y) * 2
        )
        return CGRect(center: self.center, size: rotatedSize)
    }
}
