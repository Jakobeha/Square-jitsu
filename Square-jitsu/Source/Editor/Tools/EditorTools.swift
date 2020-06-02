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
    private(set) var inspector: Inspector? = nil {
        didSet { _didChangeInspector.publish() }
    }
    /// Touch position which will cause edge panning
    private var edgePanTouchPos: TouchPos? = nil
    weak var delegate: EditorToolsDelegate? = nil
    private let world: EditableReadonlyStatelessWorld
    private let editorCamera: Camera
    private let undoManager: UndoManager
    private let userSettings: UserSettings

    var selectedTileType: TileType { tileMenu.selectedTileType }
    private var hasEditMoveState: Bool {
        switch editAction.mode {
        case .move, .copy:
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
            case .copy(selectedPositions: _, let state):
                return state
            default:
                fatalError("illegal state - tried to get edit move state but there is none")
            }
        }
        set {
            switch editAction {
            case .move(let selectedPositions, state: _):
                editAction = .move(selectedPositions: selectedPositions, state: newValue)
            case .copy(let selectedPositions, state: _):
                editAction = .copy(selectedPositions: selectedPositions, state: newValue)
            default:
                fatalError("illegal state - tried to set edit move state but there is none")
            }
        }
    }

    private let _didChangeEditSelectMode: Publisher<()> = Publisher()
    private let _didChangeEditSelection: Publisher<()> = Publisher()
    private let _didChangeEditActionMode: Publisher<()> = Publisher()
    private let _didChangeEditAction: Publisher<()> = Publisher()
    private let _didChangeInspector: Publisher<()> = Publisher()
    var didChangeEditSelectMode: Observable<()> { Observable(publisher: _didChangeEditSelectMode) }
    var didChangeEditSelection: Observable<()> { Observable(publisher: _didChangeEditSelection) }
    var didChangeEditActionMode: Observable<()> { Observable(publisher: _didChangeEditActionMode) }
    var didChangeEditAction: Observable<()> { Observable(publisher: _didChangeEditAction) }
    var didChangeInspector: Observable<()> { Observable(publisher: _didChangeInspector) }

    init(world: EditableReadonlyStatelessWorld, editorCamera: Camera, undoManager: UndoManager, userSettings: UserSettings) {
        self.world = world
        self.editorCamera = editorCamera
        self.undoManager = undoManager
        self.userSettings = userSettings
        tileMenu = TileMenu(settings: world.settings)
        tileMenu.didSelect.subscribe(observer: self, priority: .view) {
            if self.tileMenu.openLayer != nil {
                self.select(actionMode: .place)
            }
        }
    }

    // region selecting different modes
    func select(selectMode: EditSelectMode) {
        let oldEditSelectMode = editSelection.mode

        editSelection = .none(mode: selectMode)

        undoManager.registerUndo(withTarget: self) { this in
            this.editSelection = .none(mode: oldEditSelectMode)
        }
    }

    func select(actionMode: EditActionMode) {
        undoManager.beginUndoGrouping()
        let oldEditAction = editAction

        if actionMode != .place {
            let oldOpenLayer = tileMenu.openLayer

            tileMenu.openLayer = nil

            undoManager.registerUndo(withTarget: tileMenu) { tileMenu in
                tileMenu.openLayer = oldOpenLayer
            }
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

        undoManager.registerUndo(withTarget: self) { this in
            this.editAction = oldEditAction
        }
        undoManager.endUndoGrouping()
    }
    // endregion

    // region actions
    private func performCurrentAction(selectedPositions: Set<WorldTilePos3D>) {
        switch editAction {
        case .place:
            performPlaceAction(selectedPositions3D: selectedPositions)
        case .remove:
            delegate?.performRemoveAction(selectedPositions: selectedPositions)
        case .inspect:
            presentInspector(selectedPositions: selectedPositions)
        case .select(selectedPositions: let oldSelectedPositions):
            let selectedNonAirPositions = selectedPositions.filter { pos3D in world[pos3D].bigType.canBeSelected }
            let newSelectedPositions = oldSelectedPositions.union(selectedNonAirPositions)
            editAction = .select(selectedPositions: newSelectedPositions)
        case .deselect(selectedPositions: let oldSelectedPositions):
            // Don't need to filter non-air positions because those are not present either way
            let newSelectedPositions = oldSelectedPositions.subtracting(selectedPositions)
            editAction = .deselect(selectedPositions: newSelectedPositions)
        case .move(selectedPositions: _, state: _), .copy(selectedPositions: _, state: _):
            fatalError("illegal state - performCurrentAction called with move or copy action, use performMoveAction instead ")
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
            case .move, .copy, .select, .deselect:
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
        inspector = Inspector(positions: selectedPositions, world: world, delegate: delegate)
    }

    private func dismissInspector() {
        inspector = nil
    }
    // endregion

    // region touch handling
    private func afterTouchDown(touchPos: TouchPos) {
        edgePanTouchPos = touchPos

        if inspector != nil {
            dismissInspector()
        }

        if editAction.mode.requiresSelection && editAction.selectedPositions.isEmpty {
            // Move initiated with no selection, so we instant-select
            let selectedPositions = editSelection.instantSelect(touchPos: touchPos, world: world)
            switch editAction.mode {
            case .move:
                // Perform a move with these tiles - select them and then perform a move
                let nextEditMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                editAction = .move(selectedPositions: selectedPositions, state: nextEditMoveState)
            case .copy:
                // Perform a copy with these tiles
                let nextEditMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                editAction = .copy(selectedPositions: selectedPositions, state: nextEditMoveState)
            case .place, .remove, .select, .deselect, .inspect:
                fatalError("unhandled move which requires selection: \(editAction.mode)")
            }
        } else {
            if hasEditMoveState {
                // Perform a move with the selected tiles
                editMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                if editAction.mode == .move {
                    // We need to synchronize before hiding, we don't put it in temporarilyHide
                    // because it would be misleading
                    world.synchronizeInGameAndFileAt(positions: editAction.selectedPositions)
                    world.temporarilyHide(positions: editAction.selectedPositions)
                }
            } else {
                // Perform a select
                editSelection = editSelection.afterTouchDown(firstTouchPos: touchPos)
            }
        }
    }

    private func afterTouchMove(touchPos: TouchPos) {
        edgePanTouchPos = touchPos

        if hasEditMoveState && editMoveState.isStarted {
            editMoveState = editMoveState.afterTouchMove(nextTouchPos: touchPos)
        } else if !hasEditMoveState && !editSelection.isNone {
            editSelection = editSelection.afterTouchMove(nextTouchPos: touchPos)
        }
    }

    private func afterTouchUp(touchPos: TouchPos) {
        edgePanTouchPos = nil

        undoManager.beginUndoGrouping()
        let oldEditAction = editAction

        if hasEditMoveState && editMoveState.isStarted {
            if editAction.mode == .move {
                // We need to synchronize before showing, we don't put it in showTemporarilyHidden
                // because it would be misleading
                world.synchronizeInGameAndFileAt(positions: editAction.selectedPositions)
                world.showTemporarilyHidden(positions: editAction.selectedPositions)
            }

            let distanceMoved = editMoveState.distanceMovedAfterTouchUp(finalTouchPos: touchPos)
            delegate?.performMoveAction(selectedPositions: editAction.selectedPositions, distanceMoved: distanceMoved, isCopy: editAction.mode == .copy)

            editAction.selectedPositions = []
            if !editSelection.mode.canInstantSelect {
                // We need to change the mode because we can't select move without instant select ability, it's useless
                editAction = .select(selectedPositions: [])
            }
        } else if !hasEditMoveState && !editSelection.isNone {
            let selectedPositions = editSelection.getSelectedPositionsWithTilesAfterTouchUp(lastTouchPos: touchPos, world: world)
            performCurrentAction(selectedPositions: selectedPositions)
            editSelection = editSelection.endedOrCancelled
        }

        undoManager.registerUndo(withTarget: self) { this in
            this.editAction = oldEditAction
        }
        undoManager.endUndoGrouping()
    }

    private func afterTouchCancel() {
        edgePanTouchPos = nil

        if hasEditMoveState {
            if editAction.mode == .move {
                // We need to synchronize before showing, we don't put it in showTemporarilyHidden
                // because it would be misleading
                world.synchronizeInGameAndFileAt(positions: editAction.selectedPositions)
                world.showTemporarilyHidden(positions: editAction.selectedPositions)
            }

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

    // region ticking
    func tick() {
        tryEdgePan()
    }

    private func tryEdgePan() {
        if let edgePanTouchPos = edgePanTouchPos {
            for side in Side.allCases {
                let edgePanGradientPoint = userSettings.edgePanGradient.last { gradientPoint in
                    gradientPoint.distanceCutoff >= edgePanTouchPos.distancesToScreenEdges[side]
                }
                if let edgePanGradientPoint = edgePanGradientPoint {
                    edgePan(side: side, edgePanGradientPoint: edgePanGradientPoint)
                }
            }
        }
    }

    private func edgePan(side: Side, edgePanGradientPoint: EdgePanGradientPoint) {
        let speed = edgePanGradientPoint.speedInPixelsPerSecond / world.settings.tileViewWidthHeight
        let offsetDistance = speed * world.settings.fixedDeltaTime
        let offset = CGPoint(magnitude: offsetDistance, sideDirection: side)
        editorCamera.position += offset
    }
    // endregion
}
