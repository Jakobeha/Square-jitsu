//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class EditorTools {
    private(set) var editSelectMode: EditSelectMode = .rect
    private(set) var editSelection: EditSelection = EditSelection.none(mode: .rect)
    var editAction: EditAction = .place
    var tileMenu: TileMenu = TileMenu()
    private var inspector: Inspector? = nil
    weak var delegate: EditorToolsDelegate? = nil
    weak var world: ReadonlyWorld! = nil

    var selectedTileType: TileType { tileMenu.selectedTileType }
    private var hasEditMoveState: Bool {
        switch editAction {
        case .move(selectedPositions: _, state: _):
            return true
        default:
            return false
        }
    }
    private var editMoveState: EditMoveState {
        get {
            switch editAction {
            case .move(selectedPositions: _, let state):
                return state
            default:
                fatalError("illegal state - tried to get edit move state but there is none")
            }
        }
        set {
            switch editAction {
            case .move(let selectedPositions, state: _):
                editAction = .move(selectedPositions: selectedPositions, state: newValue)
            default:
                fatalError("illegal state - tried to set edit move state but there is none")
            }
        }
    }

    func select(selectMode: EditSelectMode) {
        editSelectMode = selectMode
        editSelection = .none(mode: selectMode)
    }

    func select(actionMode: EditActionMode) {
        editAction = EditAction(mode: actionMode, selectedPositions: editAction.selectedPositions)
        editSelection = editSelection.endedOrCancelled
        if editAction.mode == .inspect {
            presentInspector()
        }
    }

    func afterTouchDown(touchPos: TouchPos, totalNumTouches: Int) {
        if inspector != nil {
            dismissInspector()
        }

        if hasEditMoveState {
            // Perform a move action (if totalNumTouches == 1)
            editMoveState = totalNumTouches > 1 ? EditMoveState.notStarted : editMoveState.afterTouchDown(firstTouchPos: touchPos)
        } else {
            // Perform a select (or place or remove; if totalNumTouches == 1)
            editSelection = totalNumTouches > 1 ? editSelection.endedOrCancelled : editSelection.afterTouchDown(firstTouchPos: touchPos)
        }
    }

    func afterTouchMove(touchPos: TouchPos, totalNumTouches: Int) {
        if totalNumTouches > 1 {
            assert(editSelection.isNone && (!hasEditMoveState || !editMoveState.isStarted)) // also assume that there is no editMoveState
        } else if hasEditMoveState && editMoveState.isStarted {
            editMoveState = editMoveState.afterTouchMove(nextTouchPos: touchPos)
        } else if !hasEditMoveState && !editSelection.isNone {
            editSelection = editSelection.afterTouchMove(nextTouchPos: touchPos)
        }
    }

    func afterTouchUp(touchPos: TouchPos, totalNumTouches: Int) {
        if totalNumTouches > 1 {
            assert(editSelection.isNone && (!hasEditMoveState || !editMoveState.isStarted)) // also assume that there is no editMoveState
        } else if hasEditMoveState && editMoveState.isStarted {
            let distanceMoved = editMoveState.distanceMovedAfterTouchUp(finalTouchPos: touchPos)
            delegate?.performMoveAction(selectedPositions: editAction.selectedPositions, distanceMoved: distanceMoved)
            editMoveState = .notStarted
        } else if !hasEditMoveState && !editSelection.isNone {
            let selectedPositions = editSelection.getSelectedPositionsAfterTouchUp(lastTouchPos: touchPos, world: world)
            performCurrentAction(selectedPositions: selectedPositions)
            editSelection = editSelection.endedOrCancelled
        }
    }

    func afterCancel() {
        if hasEditMoveState {
            editMoveState = .notStarted
        } else {
            editSelection = editSelection.endedOrCancelled
        }
    }

    func performCurrentAction(selectedPositions: Set<WorldTilePos3D>) {
        switch editAction {
        case .place:
            delegate?.performPlaceAction(selectedPositions: selectedPositions, selectedTileType: selectedTileType)
        case .remove:
            delegate?.performRemoveAction(selectedPositions: selectedPositions)
        case .select(selectedPositions: let oldSelectedPositions):
            let newSelectedPositions = oldSelectedPositions.union(selectedPositions)
            editAction = .select(selectedPositions: newSelectedPositions)
        case .move(selectedPositions: _, state: _), .inspect(selectedPositions: _):
            fatalError("illegal state - performCurrentAction called with .move or .inspect actions, use performMoveAction or performInspectAction instead ")
        }
    }

    func presentInspector() {
        assert(editAction.mode == EditActionMode.inspect)
        inspector = Inspector(positions: editAction.selectedPositions, delegate: delegate, world: world)
    }

    func dismissInspector() {
        inspector = nil
    }
}
