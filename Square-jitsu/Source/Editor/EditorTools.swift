//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorTools {
    private(set) var editSelection: EditSelection = EditSelection.none(mode: .rect) {
        didSet {
            if oldValue.mode != editSelection.mode {
                _didChangeEditSelectMode.publish()
            }
            _didChangeEditSelection.publish()
        }
    }
    var editAction: EditAction = .place {
        didSet {
            if oldValue.mode != editAction.mode {
                _didChangeEditActionMode.publish()
            }
            _didChangeEditAction.publish()
        }
    }
    let tileMenu: TileMenu
    private var inspector: Inspector? = nil
    weak var delegate: EditorToolsDelegate? = nil
    private let world: ReadonlyWorld
    private let editorCamera: Camera
    private let userSettings: UserSettings

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

    private let _didChangeEditSelectMode: Publisher<()> = Publisher()
    private let _didChangeEditSelection: Publisher<()> = Publisher()
    private let _didChangeEditActionMode: Publisher<()> = Publisher()
    private let _didChangeEditAction: Publisher<()> = Publisher()
    var didChangeEditSelectMode: Observable<()> { Observable(publisher: _didChangeEditSelectMode) }
    var didChangeEditSelection: Observable<()> { Observable(publisher: _didChangeEditSelection) }
    var didChangeEditActionMode: Observable<()> { Observable(publisher: _didChangeEditActionMode) }
    var didChangeEditAction: Observable<()> { Observable(publisher: _didChangeEditAction) }

    init(world: ReadonlyWorld, editorCamera: Camera, userSettings: UserSettings) {
        self.world = world
        self.editorCamera = editorCamera
        self.userSettings = userSettings
        tileMenu = TileMenu(settings: world.settings)
        tileMenu.didSelect.subscribe(observer: self) {
            if self.tileMenu.openLayer != nil {
                self.select(actionMode: .place)
            }
        }
    }

    func select(selectMode: EditSelectMode) {
        editSelection = .none(mode: selectMode)
    }

    func select(actionMode: EditActionMode) {
        if actionMode != .place {
            tileMenu.openLayer = nil
        }

        // Change edit action
        let selectedPositions = editAction.selectedPositions
        editAction = EditAction(mode: actionMode, selectedPositions: selectedPositions)

        // Perform current action if necessary
        performCurrentActionIfNecessaryOnSelect(selectedPositions: selectedPositions)

        // Cancel and clear edit selection if it exists (probably not)
        editSelection = editSelection.endedOrCancelled

        // Fix if we're in an illegal state
        // (since the move action requires a selection, if that is the current action
        // the current mode must support instant select)
        if actionMode.requiresSelection && !editSelection.mode.canInstantSelect && selectedPositions.isEmpty {
            select(selectMode: EditSelectMode.defaultInstantSelect)
        }
    }
    
    // region touch input adapting
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        let touchPositions = getTouchPositions(uiTouches: event?.allTouches ?? [], camera: camera, container: container)
        if touchPositions.count == 1 {
            let touchPos = touchPositions.randomElement()!
            afterTouchDown(touchPos: touchPos)
        } else {
            afterTouchCancel()
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        let touchPositions = getTouchPositions(uiTouches: event?.allTouches ?? [], camera: camera, container: container)
        if touchPositions.count == 1 {
            let touchPos = touchPositions.randomElement()!
            afterTouchMove(touchPos: touchPos)
        } else {
            pan(touchPositions: touchPositions)
            afterTouchCancel()
        }

    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        let touchPositions = getTouchPositions(uiTouches: event?.allTouches ?? [], camera: camera, container: container)
        if touchPositions.count == 1 {
            let touchPos = touchPositions.randomElement()!
            afterTouchUp(touchPos: touchPos)
        } else {
            afterTouchCancel()
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        afterTouchCancel()
    }

    private func getTouchPositions(uiTouches: Set<UITouch>, camera: Camera, container: SKScene) -> [TouchPos] {
        uiTouches.map { uiTouch in getTouchPosition(uiTouch: uiTouch, camera: camera, container: container) }
    }

    private func getTouchPosition(uiTouch: UITouch, camera: Camera, container: SKScene) -> TouchPos {
        TouchPos(uiTouch: uiTouch, camera: camera, settings: world.settings, container: container)
    }
    // endregion

    // region touch handling
    private func afterTouchDown(touchPos: TouchPos) {
        if inspector != nil {
            dismissInspector()
            editAction = .inspect(selectedPositions: [])
        }

        if editAction.mode.requiresSelection && editAction.selectedPositions.isEmpty {
            // Move initiated with no selection, so we instant-select
            let selectedPositions = editSelection.instantSelect(touchPos: touchPos, world: world)
            switch editAction.mode {
            case .move:
                // Perform a move with these tiles - select them and then perform a move
                let nextEditMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                editAction = .move(selectedPositions: selectedPositions, state: nextEditMoveState)
            case .place, .remove, .select, .deselect, .inspect:
                fatalError("unhandled move which requires selection: \(editAction.mode)")
            }
        } else {
            if hasEditMoveState {
                // Perform a move with the selected tiles
                editMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                world.temporarilyHide(positions: editAction.selectedPositions)
            } else {
                // Perform a select
                editSelection = editSelection.afterTouchDown(firstTouchPos: touchPos)
            }
        }
    }

    private func afterTouchMove(touchPos: TouchPos) {
        if hasEditMoveState && editMoveState.isStarted {
            editMoveState = editMoveState.afterTouchMove(nextTouchPos: touchPos)
        } else if !hasEditMoveState && !editSelection.isNone {
            editSelection = editSelection.afterTouchMove(nextTouchPos: touchPos)
        }
    }

    private func afterTouchUp(touchPos: TouchPos) {
        if hasEditMoveState && editMoveState.isStarted {
            let distanceMoved = editMoveState.distanceMovedAfterTouchUp(finalTouchPos: touchPos)
            delegate?.performMoveAction(selectedPositions: editAction.selectedPositions, distanceMoved: distanceMoved)
            if editSelection.mode.canInstantSelect {
                editAction = .move(selectedPositions: [], state: .notStarted)
            } else {
                // We need to change the mode because we can't select move without instant select ability, it's useless
                editAction = .select(selectedPositions: [])
            }
        } else if !hasEditMoveState && !editSelection.isNone {
            let selectedPositions = editSelection.getSelectedPositionsWithTilesAfterTouchUp(lastTouchPos: touchPos, world: world)
            performCurrentAction(selectedPositions: selectedPositions)
            editSelection = editSelection.endedOrCancelled
        }
    }

    private func afterTouchCancel() {
        if hasEditMoveState {
            world.showTemporarilyHidden(positions: editAction.selectedPositions)
            editMoveState = .notStarted
        } else {
            editSelection = editSelection.endedOrCancelled
        }
    }


    private func pan(touchPositions: [TouchPos]) {
        let touchOffsets = touchPositions.map { touchPos in touchPos.worldPosDelta }
        if !touchOffsets.isEmpty {
            let worldOffset = -touchOffsets.average()! * userSettings.panMultiplierFromScreenOffsetToWorldOffset
            editorCamera.position += worldOffset
        }
    }
    // endregion

    // region actions
    private func performCurrentAction(selectedPositions: Set<WorldTilePos3D>) {
        switch editAction {
        case .place:
            performPlaceAction(selectedPositions3D: selectedPositions)
        case .remove:
            delegate?.performRemoveAction(selectedPositions: selectedPositions)
        case .select(selectedPositions: let oldSelectedPositions):
            let selectedNonAirPositions = selectedPositions.filter { pos3D in world[pos3D] != TileType.air }
            let newSelectedPositions = oldSelectedPositions.union(selectedNonAirPositions)
            editAction = .select(selectedPositions: newSelectedPositions)
        case .deselect(selectedPositions: let oldSelectedPositions):
            // Don't need to filter non-air positions because those are not present either way
            let newSelectedPositions = oldSelectedPositions.subtracting(selectedPositions)
            editAction = .deselect(selectedPositions: newSelectedPositions)
        case .move(selectedPositions: _, state: _), .inspect(selectedPositions: _):
            fatalError("illegal state - performCurrentAction called with .move or .inspect actions, use performMoveAction or performInspectAction instead ")
        }
    }

    private func performCurrentActionIfNecessaryOnSelect(selectedPositions: Set<WorldTilePos3D>) {
        // Technically the if is redundant because you can't perform an action without selected positions,
        // except for inspect (only because we assert selected positions is nonempty)
        if !selectedPositions.isEmpty {
            switch editAction.mode {
            case .place:
                performPlaceAction(selectedPositions3D: selectedPositions)
            case .remove:
                delegate?.performRemoveAction(selectedPositions: selectedPositions)
            case .inspect:
                presentInspector(selectedPositions: selectedPositions)
            case .move, .select, .deselect:
                // Not necessary on select
                break
            }
        }
    }

    private func performPlaceAction(selectedPositions3D: Set<WorldTilePos3D>) {
        let selectedPositions2D = Set(selectedPositions3D.map { pos3D in pos3D.pos })
        delegate?.performPlaceAction(selectedPositions2D: selectedPositions2D, selectedTileType: selectedTileType)
    }

    private func presentInspector(selectedPositions: Set<WorldTilePos3D>) {
        assert(editAction.mode == EditActionMode.inspect && !selectedPositions.isEmpty)
        inspector = Inspector(positions: selectedPositions, delegate: delegate, world: world)
    }

    private func dismissInspector() {
        inspector = nil
    }
    // endregion
}
