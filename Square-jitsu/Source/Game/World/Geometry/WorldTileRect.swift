//
// Created by Jakob Hain on 7/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct WorldTileRect {
    static let zero: WorldTileRect = WorldTileRect(maxX: 0, maxY: 0, minX: 0, minY: 0)

    /// Returns a rectangle containing all tiles intersected by a square or circle at the given point,
    /// with the given half side-length or radius
    static func around(center: CGPoint, radius: CGFloat) -> WorldTileRect {
        WorldTileRect(
            maxX: Int(round(center.x + radius)),
            maxY: Int(round(center.y + radius)),
            minX: Int(round(center.x - radius)),
            minY: Int(round(center.y - radius))
        )
    }

    /// Returns a rectangle containing all tiles inside of the `CGRect`
    static func around(cgRect: CGRect) -> WorldTileRect {
        WorldTileRect(
            maxX: Int(round(cgRect.maxX)),
            maxY: Int(round(cgRect.maxY)),
            minX: Int(round(cgRect.minX)),
            minY: Int(round(cgRect.minY))
        )
    }

    var maxX: Int
    var maxY: Int
    var minX: Int
    var minY: Int

    init(maxX: Int, maxY: Int, minX: Int, minY: Int) {
        assert(maxX >= minX && maxY >= minY)
        
        self.maxX = maxX
        self.maxY = maxY
        self.minX = minX
        self.minY = minY
    }

    func edgeAt(side: Side) -> Int {
        switch side {
        case .east:
            return maxX
        case .north:
            return maxY
        case .west:
            return minX
        case .south:
            return minY
        }
    }

    func minOn(axis: Axis) -> Int {
        switch axis {
        case .horizontal:
            return minX
        case .vertical:
            return minY
        }
    }

    func maxOn(axis: Axis) -> Int {
        switch axis {
        case .horizontal:
            return maxX
        case .vertical:
            return maxY
        }
    }
}
