//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Whether tiles are placed, removed, etc.
/// What happens to selected tiles or regions)
/// Also contains state for the action, e.g. prior selected positions if it's a select action
enum EditAction {
    case place
    case remove
    case select(selectedPositions: Set<WorldTilePos3D>)
    case deselect(selectedPositions: Set<WorldTilePos3D>)
    case move(selectedPositions: Set<WorldTilePos3D>, state: EditMoveState)
    case copy(selectedPositions: Set<WorldTilePos3D>, state: EditMoveState)
    case inspect(selectedPositions: Set<WorldTilePos3D>)

    var mode: EditActionMode {
        switch self {
        case .place:
            return .place
        case .remove:
            return .remove
        case .select(selectedPositions: _):
            return .select
        case .deselect(selectedPositions: _):
            return .deselect
        case .move(selectedPositions: _, state: _):
            return .move
        case .copy(selectedPositions: _, state: _):
            return .copy
        case .inspect(selectedPositions: _):
            return .inspect
        }
    }

    var selectedPositions: Set<WorldTilePos3D> {
        get {
            switch self {
            case .place, .remove:
                return []
            case .select(let selectedPositions):
                return selectedPositions
            case .deselect(let selectedPositions):
                return selectedPositions
            case .move(let selectedPositions, state: _):
                return selectedPositions
            case .copy(let selectedPositions, state: _):
                return selectedPositions
            case .inspect(let selectedPositions):
                return selectedPositions
            }
        }
        set {
            self = EditAction(mode: mode, selectedPositions: newValue)
        }
    }

    /// Creates an action with the given mode and an empty state
    init(mode: EditActionMode, selectedPositions: Set<WorldTilePos3D>) {
        switch mode {
        case .place:
            self = .place
        case .remove:
            self = .remove
        case .select:
            self = .select(selectedPositions: selectedPositions)
        case .deselect:
            self = .deselect(selectedPositions: selectedPositions)
        case .move:
            self = .move(selectedPositions: selectedPositions, state: EditMoveState.notStarted)
        case .copy:
            self = .copy(selectedPositions: selectedPositions, state: EditMoveState.notStarted)
        case .inspect:
            self = .inspect(selectedPositions: selectedPositions)
        }
    }
}
