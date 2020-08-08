//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum EditSelection {
    case none(mode: EditSelectMode)
    case rect(startPos: TouchPos, touchPos: TouchPos)
    case precision(backIndex: Int, touchPos: TouchPos)
    case freeHand(selectedPositions: Set<WorldTilePos>, touchPos: TouchPos)
    case sameType(backIndex: Int, touchPos: TouchPos)

    var mode: EditSelectMode {
        switch self {
        case .none(let mode):
            return mode
        case .rect(startPos: _, touchPos: _):
            return .rect
        case .precision(let backIndex, touchPos: _):
            return .precision(backIndex: backIndex)
        case .freeHand(selectedPositions: _, touchPos: _):
            return .freeHand
        case .sameType(let backIndex, touchPos: _):
            return .sameType(backIndex: backIndex)
        }
    }

    var isNone: Bool {
        switch self {
        case .none(mode: _):
            return true
        default:
            return false
        }
    }

    func instantSelect(touchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        EditSelection.instantSelect(mode: mode, touchPos: touchPos, world: world)
    }

    private static func instantSelect(mode: EditSelectMode, touchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        switch mode {
        case .precision(let backIndex):
            return precisionSelection(backIndex: backIndex, touchPos: touchPos, world: world)
        case .sameType(let backIndex):
            return sameTypeSelection(backIndex: backIndex, touchPos: touchPos, world: world)
        case .rect, .freeHand:
            fatalError("illegal state - tried to instant select but the select mode doesn't support it")
        }
    }

    func afterTouchDown(firstTouchPos: TouchPos) -> EditSelection {
        switch self {
        case .none(let mode):
            return EditSelection.afterTouchDown(mode: mode, firstTouchPos: firstTouchPos)
        default:
            fatalError("illegal state - afterTouchDown called on selection which isn't none")
        }
    }

    private static func afterTouchDown(mode: EditSelectMode, firstTouchPos: TouchPos) -> EditSelection {
        switch mode {
        case .rect:
            return .rect(startPos: firstTouchPos, touchPos: firstTouchPos)
        case .precision(let backIndex):
            return .precision(backIndex: backIndex, touchPos: firstTouchPos)
        case .freeHand:
            return .freeHand(selectedPositions: [firstTouchPos.worldTilePos], touchPos: firstTouchPos)
        case .sameType(let backIndex):
            return .sameType(backIndex: backIndex, touchPos: firstTouchPos)
        }
    }

    func afterTouchMove(nextTouchPos: TouchPos) -> EditSelection {
        switch self {
        case .none(mode: _):
            fatalError("illegal state - afterTouchMove called on .none selection, when touch hasn't started")
        case .rect(let startPos, touchPos: _):
            return .rect(startPos: startPos, touchPos: nextTouchPos)
        case .precision(let backIndex, touchPos: _):
            return .precision(backIndex: backIndex, touchPos: nextTouchPos)
        case .freeHand(let selectedPositions, touchPos: _):
            var nextSelectedPositions = selectedPositions
            nextSelectedPositions.insert(nextTouchPos.worldTilePos)
            return .freeHand(selectedPositions: nextSelectedPositions, touchPos: nextTouchPos)
        case .sameType(let backIndex, touchPos: _):
            return .sameType(backIndex: backIndex, touchPos: nextTouchPos)
        }
    }

    func getSelectedPositionsWithTilesAfterTouchUp(lastTouchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        let lastSelection = afterTouchMove(nextTouchPos: lastTouchPos)
        return lastSelection.getSelectedPositions(world: world)
    }

    func getSelectedPositions(world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        switch self {
        case .none(mode: _):
            return []
        case .rect(let startPos, let touchPos):
            return EditSelection.rectSelection(startPos: startPos, touchPos: touchPos, world: world)
        case .precision(let backIndex, let touchPos):
            return EditSelection.precisionSelection(backIndex: backIndex, touchPos: touchPos, world: world)
        case .freeHand(let selectedPositions, touchPos: _):
            return EditSelection.freeHandSelection(selectedPositions: selectedPositions, world: world)
        case .sameType(let backIndex, let touchPos):
            return EditSelection.sameTypeSelection(backIndex: backIndex, touchPos: touchPos, world: world)
        }
    }

    var endedOrCancelled: EditSelection {
        .none(mode: mode)
    }

    private static func rectSelection(startPos: TouchPos, touchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        Set(FBRange(startPos.worldTilePos.x, touchPos.worldTilePos.x).flatMap { x in
            FBRange(startPos.worldTilePos.y, touchPos.worldTilePos.y).flatMap { y -> [WorldTilePos3D] in
                let pos = WorldTilePos(x: x, y: y)
                return (0..<Chunk.numLayers).map { layer in WorldTilePos3D(pos: pos, layer: layer) }
            }
        })
    }

    private static func precisionSelection(backIndex: Int, touchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        let tilePos = touchPos.worldTilePos
        let tileLayer = TileType.indexOfNthHighestLayerIn(array: world[tilePos], n: backIndex)
        let tilePos3D = WorldTilePos3D(pos: tilePos, layer: tileLayer)
        return [tilePos3D]
    }

    private static func freeHandSelection(selectedPositions: Set<WorldTilePos>, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        Set(selectedPositions.flatMap { pos in
            (0..<Chunk.numLayers).map { layer in WorldTilePos3D(pos: pos, layer: layer) }
        })
    }

    private static func sameTypeSelection(backIndex: Int, touchPos: TouchPos, world: ReadonlyStatelessWorld) -> Set<WorldTilePos3D> {
        let tilePos = touchPos.worldTilePos
        let tileLayer = TileType.indexOfNthHighestLayerIn(array: world[tilePos], n: backIndex)
        let tilePos3D = WorldTilePos3D(pos: tilePos, layer: tileLayer)
        if world[tilePos3D] == TileType.air {
            return []
        } else {
            let rawPositions = world.getSideAdjacentsWithSameTypeAsTileAndDependentsAt(pos3D: tilePos3D)
            return world.extendFillersIn(positions: rawPositions)
        }
    }
}
