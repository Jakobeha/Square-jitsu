//
// Created by Jakob Hain on 6/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

extension CGPath {
    static func centeredCircle(radius: CGFloat) -> CGPath {
        CGPath(ellipseIn: CGRect(center: CGPoint.zero, size: CGSize.square(sideLength: radius * 2)), transform: nil)
    }

    static func of(line: LineSegment) -> CGPath {
        let path = CGMutablePath()
        path.move(to: line.start)
        path.addLine(to: line.end)
        return path
    }
}
