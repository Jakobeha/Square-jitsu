//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct WorldTilePos: Equatable, Hashable {
    static let zero: WorldTilePos = WorldTilePos(x: 0, y: 0)

    static func closestTo(pos: CGPoint) -> WorldTilePos {
        WorldTilePos(x: Int(pos.x.rounded()), y: Int(pos.y.rounded()))
    }

    /// The tile positions forming a square with side length 2 * distance,
    /// starting from the right going counter-clockwise
    static func sweepSquare(center: WorldTilePos, distance: Int) -> [WorldTilePos] {
        distance == 0 ? [center] :
                FBRange(center.y, center.y + distance).map { y in WorldTilePos(x: center.x + distance, y: y) } +
                FBRange(center.x + distance - 1, center.x - distance).map { x in WorldTilePos(x: x, y: center.y + distance) } +
                FBRange(center.y + distance - 1, center.y - distance).map { y in WorldTilePos(x: center.x - distance, y: y) } +
                FBRange(center.x - distance + 1, center.x + distance).map { x in WorldTilePos(x: x, y: center.y - distance) } +
                FBRange(center.y - distance + 1, center.y + distance).map { y in WorldTilePos(x: center.x + distance, y: y) }
    }

    /// A path made up of squares covering each of the tiles, possibly optimized.
    /// Returns nil if `positions` is empty.
    /// `scale` is provided because this is used for views that want paths in screen coordinates
    static func pathOfShapeMadeBy(positions: Set<WorldTilePos>, scale: CGFloat, offset: CGPoint) -> CGPath? {
        if positions.isEmpty {
            return nil
        } else {
            let path = CGMutablePath()

            // TODO: Fancier path with no positions in-between
            for position in positions {
                path.addRect(position.cgBounds.offsetBy(vector: offset).scaleCoordsBy(scale: scale))
            }

            return path
        }
    }

    private static func clustersFrom(positions: Set<WorldTilePos>) -> Set<Set<WorldTilePos>> {
        var remainingPositions = positions
        var clusters: Set<Set<WorldTilePos>> = []
        while !remainingPositions.isEmpty {
            var cluster: Set<WorldTilePos> = []

            let sweepCenter = remainingPositions.removeFirst()
            var curSweepDistance = 1
            while true {
                let nextSweep = sweepSquare(center: sweepCenter, distance: curSweepDistance).filter { position in
                    remainingPositions.contains(position)
                }

                if nextSweep.isEmpty {
                    break
                }

                remainingPositions.subtract(nextSweep)
                cluster.formUnion(nextSweep)
                curSweepDistance += 1
            }

            clusters.insert(cluster)
        }

        return clusters
    }

    static func groupByChunkPositions<TilePosCollection: Collection>(_ worldPositions: TilePosCollection) -> [WorldChunkPos:Set<ChunkTilePos>] where TilePosCollection.Element == WorldTilePos {
        (Dictionary(grouping: worldPositions) { pos in pos.worldChunkPos }).mapValues { positionsAtWorldChunkPos in
            Set(positionsAtWorldChunkPos.map { pos in pos.chunkTilePos })
        }
    }

    static func +(lhs: WorldTilePos, offset: RelativePos) -> WorldTilePos {
        WorldTilePos(x: lhs.x + offset.x, y: lhs.y + offset.y)
    }

    static func -(lhs: WorldTilePos, rhs: WorldTilePos) -> RelativePos {
        RelativePos(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    let x: Int
    let y: Int

    var worldChunkPos: WorldChunkPos {
        WorldChunkPos(x: x.floorQuotient(dividingBy: Chunk.widthHeight), y: y.floorQuotient(dividingBy: Chunk.widthHeight))
    }

    var chunkTilePos: ChunkTilePos {
        ChunkTilePos(x: x.positiveRemainder(dividingBy: Chunk.widthHeight), y: y.positiveRemainder(dividingBy: Chunk.widthHeight))
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    var cgBounds: CGRect {
        CGRect(center: cgPoint, size: CGSize.unit)
    }

    var cornerAdjacents: DenseEnumMap<Corner, WorldTilePos> {
        DenseEnumMap { corner in self + corner.offset }
    }

    var sideAdjacents: DenseEnumMap<Side, WorldTilePos> {
        DenseEnumMap { side in self + side.offset }
    }

    init(worldChunkPos: WorldChunkPos, chunkTilePos: ChunkTilePos) {
        self.init(
                x: (worldChunkPos.x * Chunk.widthHeight) + chunkTilePos.x,
                y: (worldChunkPos.y * Chunk.widthHeight) + chunkTilePos.y
        )
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
