//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Line {
    enum Slope {
        case thisIsAPoint(this: CGPoint)
        case moreHorizontal(yDivX: CGFloat)
        case moreVertical(xDivY: CGFloat)
    }

    let start: CGPoint
    let end: CGPoint

    init(start: CGPoint, offset: CGPoint) {
        self.init(start: start, end: start + offset)
    }

    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }

    var bounds: CGRect {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var vector: CGPoint {
        end - start
    }

    var length: CGFloat {
        vector.magnitude
    }

    var slope: Slope {
        if (vector.magnitude < CGFloat(Constants.epsilon)) {
            return .thisIsAPoint(this: self.start)
        } else {
            let yDivX = vector.y / vector.x
            if (yDivX.magnitude > 1) {
                return .moreVertical(xDivY: vector.x / vector.y)
            } else {
                return .moreHorizontal(yDivX: vector.y / vector.x)
            }
        }
    }

    func xAt(y: CGFloat) -> CGFloat {
        assert(y >= bounds.minY && y <= bounds.maxY)
        let lerp = (y - start.y) / (end.y - start.y)
        return lerp(t: lerp)
    }

    func yAt(x: CGFloat) -> CGFloat {
        assert(x >= bounds.minY && x <= bounds.maxY)
        let lerp = (x - start.x) / (end.x - start.x)
        return lerp(t: lerp)
    }

    /// Returns the point the given fraction along the path from start to end (e.g. t: 0 = start, t: 1 = end)
    func lerp(t lerp: CGFloat) -> CGFloat {
        CGFloat.lerp(start: start.x, end: end.x, t: lerp)
    }

    func getClosestFractionTo(point: CGPoint) -> CGFloat {
        if (length < CGFloat(Constants.epsilon)) {
            return 0
        } else {
            let offset = point - start
            let offsetProjectionLength = CGPoint.dot(offset, vector.normalized)
            return offsetProjectionLength / length
        }
    }

    /// Returns the tiles intersected by an object of radius moving along this line,
    /// ordered so that the first tiles are at the line's start and the last are at its end
    func capsuleCastTilePositions(capsuleRadius: CGFloat) -> [WorldTilePos] {
        switch slope {
        case .thisIsAPoint(let this):
            let minX = Int(floor(this.x - capsuleRadius))
            let maxX = Int(ceil(this.x + capsuleRadius))
            let minY = Int(floor(this.y - capsuleRadius))
            let maxY = Int(ceil(this.y + capsuleRadius))
            return (minX...maxX).flatMap { x in
                (minY...maxY).map { y in
                    WorldTilePos(x: x, y: y)
                }
            }
        case .moreHorizontal(let yDivX):
            let minX = Int(floor(bounds.minX - capsuleRadius))
            let maxX = Int(ceil(bounds.maxX + capsuleRadius))
            let slopeExtension = yDivX / 2
            let safeCapsuleRadius = capsuleRadius + slopeExtension
            let xs = start.x > end.x ? minX...maxX : maxX...minX
            return xs.flatMap { x -> [WorldTilePos] in
                let yOnSelf = yAt(x: CGFloat(x))
                let minY = Int(floor(yOnSelf - safeCapsuleRadius))
                let maxY = Int(ceil(yOnSelf + safeCapsuleRadius))
                let ys = start.y > end.y ? minY...maxY : maxY...minY
                return ys.map { y in
                    WorldTilePos(x: x, y: y)
                }
            }
        case .moreVertical(let xDivY):
            let minY = Int(floor(bounds.minY - capsuleRadius))
            let maxY = Int(ceil(bounds.maxY + capsuleRadius))
            let slopeExtension = xDivY / 2
            let safeCapsuleRadius = capsuleRadius + slopeExtension
            let ys = start.y > end.y ? minY...maxY : maxY...minY
            return ys.flatMap { y -> [WorldTilePos] in
                let yOnSelf = xAt(y: CGFloat(y))
                let minX = Int(floor(yOnSelf - safeCapsuleRadius))
                let maxX = Int(ceil(yOnSelf + safeCapsuleRadius))
                let xs = start.x > end.x ? minX...maxX : maxX...minX
                return xs.map { x in
                    WorldTilePos(x: x, y: y)
                }
            }
        }
    }

    /// If an object traveling this line with the given radius intersects the given point, returns the fraction along this line.
    /// Otherwise returns NaN
    func capsuleCastIntersection(capsuleRadius: CGFloat, point: CGPoint) -> CGFloat {
        let closestToPointFraction = getClosestFractionTo(point: point)
        let closestToPoint = lerp(t: closestToPointFraction)
        let distanceFromPoint = (closestToPoint - point).magnitude
        if (distanceFromPoint > capsuleRadius) {
            return CGFloat.nan
        } else {
            return closestToPointFraction
        }
    }
}
