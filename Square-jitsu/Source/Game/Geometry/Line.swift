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

    var offset: CGPoint {
        end - start
    }

    var length: CGFloat {
        offset.magnitude
    }

    var slope: Slope {
        if (offset.magnitude < Constants.cgEpsilon) {
            return .thisIsAPoint(this: self.start)
        } else {
            let yDivX = offset.y / offset.x
            if (yDivX.magnitude > 1) {
                return .moreVertical(xDivY: offset.x / offset.y)
            } else {
                return .moreHorizontal(yDivX: offset.y / offset.x)
            }
        }
    }

    func tAt(x: CGFloat) -> CGFloat? {
        if x >= bounds.minX && x <= bounds.maxX {
            return unclampedTAt(x: x)
        } else {
            return nil
        }
    }

    func tAt(y: CGFloat) -> CGFloat? {
        if y >= bounds.minY && y <= bounds.maxY {
            return unclampedTAt(y: y)
        } else {
            return nil
        }
    }

    func unclampedTAt(x: CGFloat) -> CGFloat {
        (x - start.x) / (end.x - start.x)
    }

    func unclampedTAt(y: CGFloat) -> CGFloat {
        (y - start.y) / (end.y - start.y)
    }

    func yAt(x: CGFloat) -> CGFloat? {
        if x >= bounds.minX && x <= bounds.maxX {
            return unclampedYAt(x: x)
        } else {
            return nil
        }
    }

    func xAt(y: CGFloat) -> CGFloat? {
        if y >= bounds.minY && y <= bounds.maxY {
            return unclampedXAt(y: y)
        } else {
            return nil
        }
    }

    func unclampedYAt(x: CGFloat) -> CGFloat {
        let t = unclampedTAt(x: x)
        return lerp(t: t).y
    }

    func unclampedXAt(y: CGFloat) -> CGFloat {
        let t = unclampedTAt(y: y)
        return lerp(t: t).x
    }

    /// Returns the point the given fraction along the path from start to end (e.g. t: 0 = start, t: 1 = end)
    func lerp(t lerp: CGFloat) -> CGPoint {
        CGPoint.lerp(start: start, end: end, t: lerp)
    }

    func getClosestFractionTo(point: CGPoint) -> CGFloat {
        if (length < Constants.cgEpsilon) {
            return 0
        } else {
            let offset = point - start
            let offsetProjectionLength = CGPoint.dot(offset, offset.normalized)
            return offsetProjectionLength / length
        }
    }


    func extendedBackwardsBy(magnitude: CGFloat) -> Line {
        let backwardsOffset = offset.normalized * -magnitude
        return Line(start: start + backwardsOffset, end: end)
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
            let xs = start.x > end.x ? FBRange(maxX, minX) : FBRange(minX, maxX)
            return xs.flatMap { x -> [WorldTilePos] in
                let yOnSelf = unclampedYAt(x: CGFloat(x))
                let minY = Int(floor(yOnSelf - safeCapsuleRadius))
                let maxY = Int(ceil(yOnSelf + safeCapsuleRadius))
                let ys = start.y > end.y ? FBRange(maxY, minY) : FBRange(minY, maxY)
                return ys.map { y in
                    WorldTilePos(x: x, y: y)
                }
            }
        case .moreVertical(let xDivY):
            let minY = Int(floor(bounds.minY - capsuleRadius))
            let maxY = Int(ceil(bounds.maxY + capsuleRadius))
            let slopeExtension = xDivY / 2
            let safeCapsuleRadius = capsuleRadius + slopeExtension
            let ys = start.y > end.y ? FBRange(maxY, minY) : FBRange(minY, maxY)
            return ys.flatMap { y -> [WorldTilePos] in
                let xOnSelf = unclampedXAt(y: CGFloat(y))
                let minX = Int(floor(xOnSelf - safeCapsuleRadius))
                let maxX = Int(ceil(xOnSelf + safeCapsuleRadius))
                let xs = start.x > end.x ? FBRange(maxX, minX) : FBRange(minX, maxX)
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
