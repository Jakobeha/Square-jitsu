//
// Created by Jakob Hain on 6/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

protocol WritableStatelessWorld: ReadonlyStatelessWorld {
    func setInternally(pos3D: WorldTilePos3D, to: TileType)
    func createTileInternally(pos: WorldTilePos, explicitLayer: Int?, type: TileType, force: Bool) -> Int?
    /// Technically this is equivalent to setting all tiles at the position to air,
    /// but the specific implementation could be faster
    func destroyTilesInternally(pos: WorldTilePos)
    /// Technically this is equivalent to setting the tile to air,
    /// but the specific implementation could be faster
    func destroyTileInternally(pos3D: WorldTilePos3D)

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
    /// - Note: "create" is distinguished from "place" are different in that "create" means e.g. the user explicitly
    ///   places the tile, while "place" may mean it was loaded
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

    /// Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    /// deletes the tile, while "remove" may mean it was unloaded
    func destroyTiles(pos: WorldTilePos) {
        destroyTilesDependentOn(pos: pos)
        destroyTilesInternally(pos: pos)
        finishDestroyingTilesAt(pos: pos)
    }

    /// Note: "destroy" is distinguished from "remove" are different in that "destroy" means e.g. the user explicitly
    /// deletes the tile, while "remove" may mean it was unloaded
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
        // Remove fillers to old tile
        destroyFillersTo(pos3D: pos3D, type: oldType)
        // Remove tiles which depend on the old tile to exist but can't depend on the new one
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
    // endregion
}