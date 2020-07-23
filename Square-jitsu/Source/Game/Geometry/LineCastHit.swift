//
// Created by Jakob Hain on 6/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LineCastHit {
    private let line: LineSegment
    let pos3D: WorldTilePos3D
    let tileType: TileType

    let hitPoint: CGPoint
    let hitSide: Side?

    init(line: LineSegment, pos3D: WorldTilePos3D, tileType: TileType, blockedAdjacentSides: SideSet) {
        self.line = line
        self.pos3D = pos3D
        self.tileType = tileType

        (hitPoint, hitSide) = LineCastHit.calculateHitPointAndSide(line: line, pos3D: pos3D, blockedAdjacentSides: blockedAdjacentSides)
    }

    private static func calculateHitPointAndSide(line: LineSegment, pos3D: WorldTilePos3D, blockedAdjacentSides: SideSet) -> (hitPoint: CGPoint, hitSide: Side?) {
        // Similar to in CollisionSystem we calculate which side we hit
        // except this time we don't worry about adjacents or close calls
        let xWouldHitEastSide = line.end.x < line.start.x
        let yWouldHitNorthSide = line.end.y < line.start.y
        let xSide = pos3D.pos.cgPoint.x + (xWouldHitEastSide ? 0.5 : -0.5)
        let ySide = pos3D.pos.cgPoint.y + (yWouldHitNorthSide ? 0.5 : -0.5)
        let tAtX = line.unclampedTAt(x: xSide)
        let tAtY = line.unclampedTAt(y: ySide)
        let xHitSide = xWouldHitEastSide ? Side.east : Side.west
        let yHitSide = yWouldHitNorthSide ? Side.north : Side.south
        let canHitX = !blockedAdjacentSides.contains(xHitSide.toSet)
        let canHitY = !blockedAdjacentSides.contains(yHitSide.toSet)
        if !canHitX && !canHitY {
            let t = min(tAtX, tAtY)
            let hitPoint = line.lerp(t: CGFloat.clamp(t, min: 0, max: 1))
            return (hitPoint, hitSide: nil)
        } else if !canHitY || (canHitX && tAtX < tAtY) {
            // We hit the x axis
            let hitPoint = line.lerp(t: CGFloat.clamp(tAtX, min: 0, max: 1))
            return (hitPoint, hitSide: xHitSide)
        } else {
            // We hit the y axis
            let hitPoint = line.lerp(t: CGFloat.clamp(tAtY, min: 0, max: 1))
            return (hitPoint, hitSide: yHitSide)
        }
    }
}
