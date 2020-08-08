//
// Created by Jakob Hain on 6/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol WritableStatelessWorld: ReadonlyStatelessWorld {
    func setInternally(pos3D: WorldTilePos3D, to: TileType)
    /// Technically this is equivalent to setting all tiles at the position to air,
    /// but the specific implementation could be faster
    func destroyTilesInternally(pos: WorldTilePos)

    func finishChangingTileAt(pos3D: WorldTilePos3D, type: TileType)
    func finishCreatingTileAt(pos3D: WorldTilePos3D, type: TileType)
    /// Technically this is equivalent to setting all tiles at this position to air,
    /// but the specific implementation could be faster
    func finishDestroyingTilesAt(pos: WorldTilePos)
}

extension WritableStatelessWorld {
    // region tile mutation
    subscript(pos3D: WorldTilePos3D) -> TileType {
        get { _getTileTypeAt(pos3D: pos3D) }
        set {
            destroyTilesDependentOn(pos3D: pos3D)
            setInternally(pos3D: pos3D, to: newValue)
            createFillersTo(pos3D: pos3D, force: true)
            finishChangingTileAt(pos3D: pos3D, type: newValue)
        }
    }

    /// Places the tile if there are no overlapping tiles at the given position
    /// - Returns: The layer of the tile if it was placed, otherwise nil
    @discardableResult func createTile(pos: WorldTilePos, explicitLayer: Int? = nil, type: TileType, force: Bool) -> Int? {
        guard let layer = createTileInternally(pos: pos, explicitLayer: explicitLayer, type: type, force: force) else {
            return nil
        }
        let pos3D = WorldTilePos3D(pos: pos, layer: layer)
        if !createFillersTo(pos3D: pos3D, force: force) {
            // roll back
            destroyTile(pos3D: pos3D)
            return nil
        }

        finishCreatingTileAt(pos3D: pos3D, type: type)

        return layer
    }

    func destroyTiles(pos: WorldTilePos) {
        destroyTilesDependentOn(pos: pos)
        destroyTilesInternally(pos: pos)
        finishDestroyingTilesAt(pos: pos)
    }

    func destroyTile(pos3D: WorldTilePos3D) {
        destroyTilesDependentOn(pos3D: pos3D)
        destroyTileInternally(pos3D: pos3D)
        finishChangingTileAt(pos3D: pos3D, type: TileType.air)
    }

    private func destroyTilesDependentOn(pos: WorldTilePos) {
        destroyFillersTo(pos: pos)
        // Any tiles depending on other overlapping tiles at this position are already destroyed
    }

    private func destroyTilesDependentOn(pos3D: WorldTilePos3D) {
        let oldType = self[pos3D]
        // Destroy fillers to old tile
        destroyFillersTo(pos3D: pos3D, type: oldType)
        // Destroy tiles which depend on the old tile to exist but can't depend on the new one
        destroyTilesDependentOnOverlapping(pos3D: pos3D, type: oldType)
    }

    private func destroyFillersTo(pos3D: WorldTilePos3D, type: TileType) {
        assert(self[pos3D] == type)
        for fillerPos3D in getFillerPositionsTo(pos3D: pos3D) {
            destroyTile(pos3D: fillerPos3D)
        }
    }

    private func destroyFillersTo(pos: WorldTilePos) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            let type = self[pos3D]
            destroyFillersTo(pos3D: pos3D, type: type)
        }
    }

    private func destroyTilesDependentOnOverlapping(pos3D: WorldTilePos3D, type: TileType) {
        let tilesAtPos = self[pos3D.pos]

        // This is very messy. Basically, we destroy all tiles at the same 2D position
        // which depend on overlapping this type and no other types at the position.
        for otherLayer in 0..<Chunk.numLayers {
            if otherLayer != pos3D.layer {
                let otherType = tilesAtPos[otherLayer]
                if doesType(otherType, dependOnOverlapping: type) && !(0..<Chunk.numLayers).contains(where: { thirdLayer in
                    if thirdLayer != pos3D.layer && thirdLayer != otherLayer {
                        let thirdType = tilesAtPos[thirdLayer]
                        return doesType(otherType, dependOnOverlapping: thirdType)
                    } else {
                        return false
                    }
                }) {
                    let otherPos3D = WorldTilePos3D(pos: pos3D.pos, layer: otherLayer)
                    destroyTile(pos3D: otherPos3D)
                }
            }
        }
    }

    /// Returns whether the fillers were successfully created (otherwise we need to rollback)
    @discardableResult private func createFillersTo(pos3D: WorldTilePos3D, force: Bool) -> Bool {
        var createdPositions: [WorldTilePos3D] = []
        var failed = false
        for (fillerPos, fillerType) in getIntendedMacroFillersTo(pos3D: pos3D) {
            if let layer = createTile(pos: fillerPos, type: fillerType, force: force) {
                let fillerPos3D = WorldTilePos3D(pos: fillerPos, layer: layer)
                createdPositions.append(fillerPos3D)
            } else {
                failed = true
                break
            }
        }

        if failed {
            // roll back
            for fillerPos3D in createdPositions {
                destroyTile(pos3D: fillerPos3D)
            }
        }

        return !failed
    }

    // region shared internal implementations of mutating methods
    /// Tries to create the tile, but won't create if it's meaningless
    /// (e.g. a tile which functions based on orientation but has none)
    /// or if there are other overlapping tiles which must be destroyed and the flag is set to false.
    /// If it's set to true, the overlapping tiles will be destroyed.
    /// If an explicit layer is provided and the tile is created, it will be created at said layer
    /// and the tile previously at that layer might be moved
    /// - Returns: The layer of the tile if it was created, otherwise nil
    @discardableResult func createTileInternally(pos: WorldTilePos, explicitLayer: Int?, type: TileType, force: Bool) -> Int? {
        guard let originalLayer = createTileInternally(pos: pos, type: type, force: force) else {
            return nil
        }

        if let explicitLayer = explicitLayer {
            if originalLayer != explicitLayer {
                // Swap so that the created layer is the explicit layer
                let originalPos3D = WorldTilePos3D(pos: pos, layer: originalLayer)
                let explicitPos3D = WorldTilePos3D(pos: pos, layer: explicitLayer)
                let intermediateTile = self[originalPos3D]

                // We use setInternally because we don't want to destroy extra tiles,
                // and we get a finishChangingTileAt event after calling this method anyways
                setInternally(pos3D: originalPos3D, to: self[explicitPos3D])
                setInternally(pos3D: explicitPos3D, to: intermediateTile)
            }

            return explicitLayer
        } else {
            return originalLayer
        }
    }

    /// Tries to create the tile, but won't create if it's meaningless
    /// (e.g. a tile which functions based on orientation but has none)
    /// or if there are other overlapping tiles which must be destroyed and the flag is set to false.
    /// If it's set to true, the overlapping tiles will be destroyed
    /// - Returns: The layer of the tile if it was created, otherwise nil
    @discardableResult func createTileInternally(pos: WorldTilePos, type: TileType, force: Bool) -> Int? {
        if force {
            return forceCreateTileInternally(pos: pos, type: type)
        } else {
            return tryCreateTileInternally(pos: pos, type: type)
        }
    }

    /// Creates the tile if there are no overlapping tiles
    /// - Returns: The layer of the tile if it was created, otherwise nil
    @discardableResult private func tryCreateTileInternally(pos: WorldTilePos, type: TileType) -> Int? {
        if type.isMeaninglessInGame {
            return nil
        } else {
            if let layer = getLayerWithSameNotOrientedType(pos: pos, type: type.withDefaultOrientation) {
                if type.bigType.layer.doTilesOccupySides {
                    let pos3D = WorldTilePos3D(pos: pos, layer: layer)

                    var type = self[pos3D]
                    type.orientation.asSideSet.formUnion(type.orientation.asSideSet)
                    setInternally(pos3D: pos3D, to: type)

                    return layer
                } else {
                    return nil
                }
            } else {
                if !hasOverlappingTiles(pos: pos, type: type) {
                    assert(hasFreeLayerAt(pos: pos), "there are no overlapping tiles but no free layer, this isn't allowed - num layers should be increased")
                    return createTileInternallyInFreeLayer(pos: pos, type: type)
                } else {
                    return nil
                }
            }
        }
    }

    /// Creates the tile, removing any non-overlapping tiles. The tile still won't be created if it's meaningless
    /// (e.g. a tile which functions based on its orientation, but has none)
    /// - Returns: The layer of the tile if it was created, otherwise nil
    @discardableResult private func forceCreateTileInternally(pos: WorldTilePos, type: TileType) -> Int? {
        if type.isMeaninglessInGame {
            return nil
        } else {
            if let layer = getLayerWithSameNotOrientedType(pos: pos, type: type.withDefaultOrientation) {
                let pos3D = WorldTilePos3D(pos: pos, layer: layer)
                setInternally(pos3D: pos3D, to: self[pos3D].mergedOrReplaced(orientation: type.orientation))
                return layer
            } else {
                destroyNonOverlappingTiles(pos: pos, type: type)
                return createTileInternallyInFreeLayer(pos: pos, type: type)
            }
        }
    }

    private func destroyNonOverlappingTiles(pos: WorldTilePos, type: TileType) {
        for layer in 0..<Chunk.numLayers {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            let pos3DFollowingFillers = followFillersAt(pos3D: pos3D, type: .macro)
            let existingType = self[pos3DFollowingFillers]
            if !TileType.typesCanOverlap(type, existingType) {
                destroyTile(pos3D: pos3D)
            }
        }

        // Still need to destroy a tile if there is no free chunk layer.
        // We could destroy one at any layer (all layers are occupied),
        // but we choose the last one
        if !hasFreeLayerAt(pos: pos) {
            let layerToFree = Chunk.numLayers - 1
            destroyTile(pos3D: WorldTilePos3D(pos: pos, layer: layerToFree))
        }
    }

    private func hasOverlappingTiles(pos: WorldTilePos, type: TileType) -> Bool {
        // We go backwards because removing earlier tiles moves later ones down
        for layer in (0..<Chunk.numLayers).reversed() {
            let pos3D = WorldTilePos3D(pos: pos, layer: layer)
            let pos3DFollowingFillers = followFillersAt(pos3D: pos3D, type: .macro)
            let existingType = self[pos3DFollowingFillers]
            if !TileType.typesCanOverlap(type, existingType) {
                return true
            }
        }
        return false
    }

    /// Asserts that there is a free layer at the given position.
    /// Creates the tile at that layer and returns it.
    @discardableResult private func createTileInternallyInFreeLayer(pos: WorldTilePos, type: TileType) -> Int {
        guard let layer = getNextFreeLayerAt(pos: pos) else {
            fatalError("createTileInFreeLayer - no free layer at \(pos)")
        }

        let pos3D = WorldTilePos3D(pos: pos, layer: layer)
        setInternally(pos3D: pos3D, to: type)

        return layer
    }

    private func getLayerWithSameNotOrientedType(pos: WorldTilePos, type: TileType) -> Int? {
        assert(type.withDefaultOrientation == type)
        return self[pos].firstIndex { otherType in otherType.withDefaultOrientation == type }
    }

    func destroyTileInternally(pos3D: WorldTilePos3D) {
        setInternally(pos3D: pos3D, to: TileType.air)
    }
    // endregion
    // endregion
}