//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum EditSelection {
    case none(mode: EditSelectMode)
    case rect(startPos: TouchPos, touchPos: TouchPos)
    case precision(touchPos: TouchPos)
    case freeHand(selectedPositions: Set<WorldTilePos>, touchPos: TouchPos)
    case sameType(touchPos: TouchPos)

    var mode: EditSelectMode {
        switch self {
        case .none(let mode):
            return mode
        case .rect(startPos: _, touchPos: _):
            return .rect
        case .precision(touchPos: _):
            return .precision
        case .freeHand(selectedPositions: _, touchPos: _):
            return .freeHand
        case .sameType(touchPos: _):
            return .sameType
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

    func tryInstantSelect(touchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        EditSelection.tryInstantSelect(mode: mode, touchPos: touchPos, world: world)
    }

    private static func tryInstantSelect(mode: EditSelectMode, touchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        switch mode {
        case .precision:
            return precisionSelection(touchPos: touchPos, world: world)
        case .sameType:
            return sameTypeSelection(touchPos: touchPos, world: world)
        case .rect, .freeHand:
            return []
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
        case .precision:
            return .precision(touchPos: firstTouchPos)
        case .freeHand:
            return .freeHand(selectedPositions: [firstTouchPos.worldTilePos], touchPos: firstTouchPos)
        case .sameType:
            return .sameType(touchPos: firstTouchPos)
        }
    }

    func afterTouchMove(nextTouchPos: TouchPos) -> EditSelection {
        switch self {
        case .none(mode: _):
            fatalError("illegal state - afterTouchMove called on .none selection, when touch hasn't started")
        case .rect(let startPos, touchPos: _):
            return .rect(startPos: startPos, touchPos: nextTouchPos)
        case .precision(touchPos: _):
            return .precision(touchPos: nextTouchPos)
        case .freeHand(let selectedPositions, touchPos: _):
            var nextSelectedPositions = selectedPositions
            nextSelectedPositions.insert(nextTouchPos.worldTilePos)
            return .freeHand(selectedPositions: nextSelectedPositions, touchPos: nextTouchPos)
        case .sameType(touchPos: _):
            return .sameType(touchPos: nextTouchPos)
        }
    }

    func getSelectedPositionsAfterTouchUp(lastTouchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        let lastSelection = afterTouchMove(nextTouchPos: lastTouchPos)
        return lastSelection.getSelectedPositions(world: world)
    }

    func getSelectedPositions(world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        switch self {
        case .none(mode: _):
            fatalError("illegal state - getSelectedPositionsAfterTouchUp called on .none selection, when touch hasn't started")
        case .rect(let startPos, let touchPos):
            return EditSelection.rectSelection(startPos: startPos, touchPos: touchPos, world: world)
        case .precision(let touchPos):
            return EditSelection.precisionSelection(touchPos: touchPos, world: world)
        case .freeHand(let selectedPositions, touchPos: _):
            return EditSelection.freeHandSelection(selectedPositions: selectedPositions, world: world)
        case .sameType(let touchPos):
            return EditSelection.sameTypeSelection(touchPos: touchPos, world: world)
        }
    }

    var endedOrCancelled: EditSelection {
        .none(mode: mode)
    }

    private static func rectSelection(startPos: TouchPos, touchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        Set(FBRange(startPos.worldTilePos.x, touchPos.worldTilePos.x).flatMap { x in
            FBRange(startPos.worldTilePos.y, touchPos.worldTilePos.y).flatMap { y -> [WorldTilePos3D] in
                let pos = WorldTilePos(x: x, y: y)
                return (0..<Chunk.numLayers).map { layer in WorldTilePos3D(pos: pos, layer: layer) }
            }
        }.filter { pos3D in world[pos3D] != TileType.air })
    }

    private static func precisionSelection(touchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        let tilePos = touchPos.worldTilePos
        let tileLayer = TileType.indexOfHighestLayerIn(array: world[tilePos])
        let tilePos3D = WorldTilePos3D(pos: tilePos, layer: tileLayer)
        if world[tilePos3D] == TileType.air {
            return []
        } else {
            return [tilePos3D]
        }
    }

    private static func freeHandSelection(selectedPositions: Set<WorldTilePos>, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        Set(selectedPositions.flatMap { pos in
            (0..<Chunk.numLayers).map { layer in WorldTilePos3D(pos: pos, layer: layer) }
        }.filter { pos3D in world[pos3D] != TileType.air })
    }

    private static func sameTypeSelection(touchPos: TouchPos, world: ReadonlyWorld) -> Set<WorldTilePos3D> {
        let tilePos = touchPos.worldTilePos
        let tileLayer = TileType.indexOfHighestLayerIn(array: world[tilePos])
        let tilePos3D = WorldTilePos3D(pos: tilePos, layer: tileLayer)
        if world[tilePos3D] == TileType.air {
            return []
        } else {
            return world.adjacentsWithSameTypeAsTileAt(pos3D: tilePos3D)
        }
    }
}
