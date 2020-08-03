//
// Created by Jakob Hain on 5/19/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol ReadonlyStatelessWorld: AnyObject {
    var settings: WorldSettings { get }

    subscript(pos: WorldTilePos) -> [TileType] { get }

    /// A subscript is provided which calls this method. Call it instead.
    /// The only reason this method exists is because a setter for said subscript is defined in an extension,
    /// and you can't define a setter without overriding the getter.
    func _getTileTypeAt(pos3D: WorldTilePos3D) -> TileType
    func getMetadataAt(pos3D: WorldTilePos3D) -> TileMetadata?
}

extension ReadonlyStatelessWorld {
    // region tile at position
    subscript(pos3D: WorldTilePos3D) -> TileType {
        _getTileTypeAt(pos3D: pos3D)
    }

    func getTileAt(pos3D: WorldTilePos3D) -> TileAtPosition {
        TileAtPosition(type: self[pos3D], position: pos3D, metadata: getMetadataAt(pos3D: pos3D))
    }

    func getUpdatedTileAtPosition(oldTileAtPosition: TileAtPosition) -> TileAtPosition {
        getTileAt(pos3D: oldTileAtPosition.position)
    }
    // endregion

    func doesType(_ dependentType: TileType, dependOnOverlapping requiredType: TileType) -> Bool {
        switch settings.tileOrientationMeanings[dependentType] ?? .unused {
        case .unused, .directionAdjacentToSolid, .freeDirection, .directionToCorner, .freeSideSet:
            return false
        case .atBackgroundBorder:
            return requiredType.isBackground
        case .atSolidBorder:
            return requiredType.isSolid
        }
    }

    // region macro tile size and fillers
    func getSizeOfTileAt(pos3D: WorldTilePos3D) -> RelativeSize {
        if let imageMetadata = getMetadataAt(pos3D: pos3D) as? ImageMetadata {
            return RelativeSize.ceil(imageMetadata.sizeInTiles)
        } else {
            let tileType = self[pos3D]
            if let sizeFromSettings = settings.macroTileSizes[tileType] {
                return sizeFromSettings
            } else {
                return RelativeSize.unit
            }
        }
    }

    // region fillers
    func getIntendedMacroFillersTo(pos3D: WorldTilePos3D) -> [(fillerPos: WorldTilePos, fillerType: TileType)] {
        let size = getSizeOfTileAt(pos3D: pos3D)

        let fillerOffsets = (0..<size.width).flatMap { x -> [RelativePos] in
            let startY = x == 0 ? 1 : 0
            return (startY..<size.height).map { y in
                RelativePos(x: x, y: y)
            }
        }

        let fillerId = (0..<TileFillerData.maxId).first { potentialFillerId in
            !fillerOffsets.contains { fillerOffset in
                let fillerPos = pos3D.pos + fillerOffset
                let typesAtFillerPos = self[fillerPos]
                return typesAtFillerPos.contains { typeAtFillerPos in
                    typeAtFillerPos.bigType == .filler &&
                    typeAtFillerPos.smallType.asFillerData.id == potentialFillerId
                }
            }
        } ?? {
            Logger.warn("fillers for tile at \(pos3D) will conflict with other fillers, because there are more overlapping fillers than there are possible filler ids")
            return TileFillerData.maxId
        }()

        return fillerOffsets.map { fillerOffset in
            print(fillerOffset)
            let fillerDirection: Side = fillerOffset.y == 0 ? .west : .south
            let fillerPos = pos3D.pos + fillerOffset
            let fillerType = TileType.filler(type: .macro, id: fillerId, direction: fillerDirection, targetLayer: pos3D.layer)
            return (fillerPos, fillerType)
        }
    }

    func getFillerPositionsTo(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        if let fillerId: Int = pos3D.pos.sideAdjacents.compactMap({ (adjacentSide, adjacentPos) in
            let typesAtAdjacentPos = self[adjacentPos]
            let directionToPos = adjacentSide.opposite
            let typeOfFiller = typesAtAdjacentPos.first { typeAtPos in
                if typeAtPos.bigType == .filler {
                    let fillerOrientationAtPos = typeAtPos.orientation.asFillerOrientation
                    return fillerOrientationAtPos.targetLayer == pos3D.layer &&
                        fillerOrientationAtPos.direction == directionToPos
                } else {
                    return false
                }
            }
            return typeOfFiller?.smallType.asFillerData.id
        }).first {
            var checkAdjacentsOfTheseWorkset: Set<WorldTilePos> = [pos3D.pos]
            var checkedPositions: Set<WorldTilePos> = []
            var fillerPositions: Set<WorldTilePos3D> = []

            // Workset algorithm which looks for connected adjacents of this position,
            // then connected adjacents of any found positions, until there are none left
            while let checkAdjacentsOfThisPos = checkAdjacentsOfTheseWorkset.popFirst() {
                for (side, adjacentPos) in checkAdjacentsOfThisPos.sideAdjacents {
                    let directionIfConnected = side.opposite
                    let adjacentTypes = self[adjacentPos]

                    for layer in 0..<Chunk.numLayers {
                        let adjacentPos3D = WorldTilePos3D(pos: adjacentPos, layer: layer)

                        if !fillerPositions.contains(adjacentPos3D) {
                            let adjacentType = adjacentTypes[layer]
                            if adjacentType.bigType == .filler &&
                               adjacentType.smallType.asFillerData.id == fillerId &&
                               adjacentType.orientation.asFillerOrientation.direction == directionIfConnected {
                                // Add position to fillers, and add to workset (if not already seen) to get fillers connected to this
                                fillerPositions.insert(adjacentPos3D)
                                if !checkedPositions.contains(adjacentPos) {
                                    checkAdjacentsOfTheseWorkset.insert(adjacentPos)
                                    checkedPositions.insert(adjacentPos)
                                }
                            }
                        }
                    }
                }
            }

            return fillerPositions
        } else {
            return []
        }
    }

    func getFillerPositionsToAndIncluding(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        var result = getFillerPositionsTo(pos3D: pos3D)
        result.insert(pos3D)
        return result
    }

    /// If the tile at the given position is a filler,
    /// retries with the tile it immediately points toward,
    /// repeated until we get a position without a filler tile.
    func followFillersAt(pos3D: WorldTilePos3D) -> WorldTilePos3D {
        let initialTile = self[pos3D]
        if initialTile.bigType != .filler {
            return pos3D
        }

        let fillerId = initialTile.smallType.asFillerData.id
        let targetLayer = initialTile.orientation.asFillerOrientation.targetLayer

        var currentPos = pos3D.pos
        var currentFiller = initialTile
        while true {
            assert(currentFiller.bigType == .filler)

            let nextPos = currentPos + currentFiller.orientation.asFillerOrientation.direction.perpendicularOffset
            let nextTiles = self[nextPos]
            if let nextFiller = nextTiles.first(where: { nextTile in
                nextTile.bigType == .filler && nextTile.smallType.asFillerData.id == fillerId
            }) {
                currentPos = nextPos
                currentFiller = nextFiller
            } else {
                // Found target
                return WorldTilePos3D(pos: nextPos, layer: targetLayer)
            }
        }
    }

    /// If the tile at the given position has or is a filler,
    /// returns the target and all other connected fillers
    func extendFillersAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        getFillerPositionsToAndIncluding(pos3D: followFillersAt(pos3D: pos3D))
    }

    /// Returns all of the tiles, as well as any connected fillers and
    /// (if any of the tiles are fillers themselves) targeted tiles.
    func extendFillersIn(positions: Set<WorldTilePos3D>) -> Set<WorldTilePos3D> {
        positions.map(extendFillersAt).reduce()
    }
    // endregion
    // endregion

    // region info at 2D pos
    func getTileLayersAt(pos: WorldTilePos) -> TileLayerSet {
        TileLayerSet(self[pos].map { tileType in tileType.bigType.layer})
    }

    func getOccupiedTileSidesAt(pos: WorldTilePos, tileLayer: TileLayer) -> SideSet {
        self[pos].filter { tileType in tileType.bigType.layer == tileLayer }.map { tileType in tileType.occupiedSides }.reduce()
    }
    // endregion

    // region adjacent info
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
    // endregion

    // region connected tiles
    /// Helper used in inspectors for macro tiles
    func getSideAdjacentsOf(tilesAtPositions: [TileAtPosition]) -> [TileAtPosition] {
        tilesAtPositions.flatMap { tileAtPosition in
            self.getSideAdjacentsWithSameTypeAsTileAt(pos3D: tileAtPosition.position).map(self.getTileAt)
        }
    }

    /// Note: doesn't return nil for air
    func getSideAdjacentsWithSameTypeAsTileAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        let type = self[pos3D]

        return getConnectedSideAdjacents(origin: pos3D) { testPos in
            let typesAtPos = self[testPos]
            // Technically it doesn't matter whether we use firstIndex or lastIndex
            if let indexWithSameTypeAtPos = typesAtPos.lastIndex(where: { typeAtPos in
                type.withDefaultOrientation == typeAtPos.withDefaultOrientation
            }) {
                return [indexWithSameTypeAtPos]
            } else {
                return []
            }
        }
    }

    /// Note: doesn't return nil for air.
    /// Returns connected tiles with the same type,
    /// and tiles which are only supposed to exist on (possibly other types or) this type,
    /// such as solid and background edge tiles.
    func getSideAdjacentsWithSameTypeAsTileAndDependentsAt(pos3D: WorldTilePos3D) -> Set<WorldTilePos3D> {
        let type = self[pos3D]

        return getConnectedSideAdjacents(origin: pos3D) { testPos in
            let typesAtPos = self[testPos]
            var connectedIndices: [Int] = []

            // Add position if the tile has the same type as the origin
            if let indexWithSameTypeAtPos = typesAtPos.lastIndex(where: { typeAtPos in
                type.withDefaultOrientation == typeAtPos.withDefaultOrientation
            }) {
                connectedIndices.append(indexWithSameTypeAtPos)

                // Add positions of tiles on this type which depend on it existing
                connectedIndices.append(contentsOf: typesAtPos.indicesWhere { typeAtPos in
                    self.doesType(typeAtPos, dependOnOverlapping: type)
                })
            }

            return connectedIndices
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
    // endregion

    // region casting
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
    // endergion
}