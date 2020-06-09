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
    let hitSide: Side

    init(line: LineSegment, pos3D: WorldTilePos3D, tileType: TileType) {
        self.line = line
        self.pos3D = pos3D
        self.tileType = tileType

        (hitPoint, hitSide) = LineCastHit.calculateHitPointAndSide(line: line, pos3D: pos3D)
    }

    private static func calculateHitPointAndSide(line: LineSegment, pos3D: WorldTilePos3D) -> (hitPoint: CGPoint, hitSide: Side) {
        // Similar to in CollisionSystem we calculate which side we hit
        // except this time we don't worry about adjacents or close calls
        let xWouldHitEastSide = line.end.x > line.start.x
        let yWouldHitSouthSide = line.end.y > line.start.y
        let xSide = pos3D.pos.cgPoint.x + (xWouldHitEastSide ? -0.5 : 0.5)
        let ySide = pos3D.pos.cgPoint.y + (yWouldHitSouthSide ? -0.5 : 0.5)
        let tAtX = line.unclampedTAt(x: xSide)
        let tAtY = line.unclampedTAt(y: ySide)
        if tAtX < tAtY {
            // We hit the x axis
            let hitPoint = line.lerp(t: tAtX)
            let hitSide = xWouldHitEastSide ? Side.east : Side.west
            return (hitPoint, hitSide)
        } else {
            // We hit the y axis
            let hitPoint = line.lerp(t: tAtY)
            let hitSide = yWouldHitSouthSide ? Side.south : Side.north
            return (hitPoint, hitSide)
        }
    }
}
