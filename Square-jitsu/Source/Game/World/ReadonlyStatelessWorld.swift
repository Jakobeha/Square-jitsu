//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol ReadonlyStatelessWorld: AnyObject {
    var settings: WorldSettings { get }

    subscript(pos: WorldTilePos) -> [TileType] { get }
    subscript(pos3D: WorldTilePos3D) -> TileType { get }

    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata?
}

extension ReadonlyStatelessWorld {
    func getTileAt(pos3D: WorldTilePos3D) -> TileAtPosition {
        TileAtPosition(type: self[pos3D], position: pos3D, metadata: getMetadataAt(pos3D: pos3D))
    }

    func getUpdatedTileAtPosition(oldTileAtPosition: TileAtPosition) -> TileAtPosition {
        getTileAt(pos3D: oldTileAtPosition.position)
    }

    func getTileLayersAt(pos: WorldTilePos) -> TileLayerSet {
        TileLayerSet(self[pos].map { tileType in tileType.bigType.layer})
    }

    func getOccupiedTileSidesAt(pos: WorldTilePos, tileLayer: TileLayer) -> SideSet {
        self[pos].filter { tileType in tileType.bigType.layer == tileLayer }.map { tileType in tileType.occupiedSides }.reduce()
    }

    func getAdjacentTileLayersAt(pos: WorldTilePos) -> DenseEnumMap<Side, TileLayerSet> {
        pos.sideAdjacents.mapValues(transform: getTileLayersAt)
    }

    func getBackgroundAdjacentSidesTo(pos: WorldTilePos) -> SideSet {
        SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            let adjacentTileTypes = self[adjacentPos]
            return adjacentTileTypes.contains { tileType in tileType.isBackground }
        })
    }

    func getSolidAdjacentSidesTo(pos: WorldTilePos) -> SideSet {
        SideSet(pos.sideAdjacents.mapValues { adjacentPos in
            let adjacentTileTypes = self[adjacentPos]
            return adjacentTileTypes.contains { tileType in tileType.isSolid }
        })
    }

    /// Note: doesn't return nil for air
    func getSideAdjacentsWithSameTypeAsTileAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        let type = self[pos3D]

        return getConnectedSideAdjacents(origin: pos3D) { testPos in
            let typesAtPos = self[testPos]
            // Technically it doesn't matter whether we use firstIndex or lastIndex
            if let indexWithSameTypeAtPos = typesAtPos.lastIndex(of: type) {
                return [indexWithSameTypeAtPos]
            } else {
                return []
            }
        }
    }

    // Return a set of all positions "connected" to the origin (including it), according to the predicate
    private func getConnectedSideAdjacents(origin: WorldTilePos3D, getConnectedLayers: (WorldTilePos) -> [Int]) -> Set<WorldTilePos3D> {
        var positions3D: Set<WorldTilePos3D> = [origin]

        var positions2DAtPrevDistance: Set<WorldTilePos> = [origin.pos]
        var distance = 0
        while !positions2DAtPrevDistance.isEmpty {
            distance += 1
            var positions2DAtNextDistance: Set<WorldTilePos> = []
            var firstTileWasConnected: Bool? = nil
            var lastTileWasConnected: Bool = false
            var maybeConnectedPositions2DAtNextDistance: Set<WorldTilePos> = []
            var maybeConnectedPositions3D: Set<WorldTilePos3D> = []

            for pos in WorldTilePos.sweepSquare(center: origin.pos, distance: distance) {
                // Technically it doesn't matter whether we use firstIndex or lastIndex
                let connectedLayers = getConnectedLayers(pos)
                for layer in connectedLayers {
                    // The world has a tile of the same type at this position - else it doesn't
                    let pos3D = WorldTilePos3D(pos: pos, layer: layer)
                    if lastTileWasConnected || positions2DAtPrevDistance.contains(anyOf: pos.sideAdjacents.values) {
                        // The tile is connected to pos3D, add it.
                        positions2DAtNextDistance.insert(pos)
                        positions3D.insert(pos3D)

                        // Also all maybe positions are also connected, from transitivity
                        positions2DAtNextDistance.formUnion(maybeConnectedPositions2DAtNextDistance)
                        positions3D.formUnion(maybeConnectedPositions3D)
                        maybeConnectedPositions2DAtNextDistance.removeAll()
                        maybeConnectedPositions3D.removeAll()

                        // Set the last-tile-connected flag
                        lastTileWasConnected = true

                        // And if this is the first tile, set the first-tile-connected flag
                        if firstTileWasConnected == nil {
                            firstTileWasConnected = true
                        }
                    } else {
                        // The tile may not be connected, or maybe it will be connected to another connected tile at
                        // this layer, and thus transitively connected
                        maybeConnectedPositions2DAtNextDistance.insert(pos)
                        maybeConnectedPositions3D.insert(pos3D)
                    }
                }
                if connectedLayers.isEmpty {
                    // The maybe-connected tiles aren't actually connected
                    maybeConnectedPositions2DAtNextDistance.removeAll()
                    maybeConnectedPositions3D.removeAll()

                    // Set the last-tile-connected flag
                    lastTileWasConnected = false

                    // And if this is the first tile, set the first-tile-connected flag
                    if firstTileWasConnected == nil {
                        firstTileWasConnected = false
                    }
                }
            }

            if firstTileWasConnected ?? false {
                // The maybe-connected tiles are connected via transitivity to the first tile in the sweep
                positions2DAtNextDistance.formUnion(maybeConnectedPositions2DAtNextDistance)
                positions3D.formUnion(maybeConnectedPositions3D)
            }

            positions2DAtPrevDistance = positions2DAtNextDistance
        }

        return positions3D
    }

    func cast(ray: Ray, maxDistance: CGFloat, hitPredicate: (TileType) -> Bool) -> LineCastHit? {
        castToSolid(line: ray.cutoffAt(distance: maxDistance), hitPredicate: hitPredicate)
    }

    func castToSolid(line: LineSegment, hitPredicate: (TileType) -> Bool) -> LineCastHit? {
        for pos in line.lineSegmentCastTilePositions() {
            for layer in 0..<Chunk.numLayers {
                let pos3D = WorldTilePos3D(pos: pos, layer: layer)
                let tileType = self[pos3D]
                if hitPredicate(tileType) {
                    let blockedAdjacentSides = SideSet(pos3D.pos.sideAdjacents.mapValues { adjacentPos in
                        self[adjacentPos].contains(where: hitPredicate)
                    })
                    return LineCastHit(line: line, pos3D: pos3D, tileType: tileType, blockedAdjacentSides: blockedAdjacentSides)
                }
            }
        }
        return nil
    }
}