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
    let world: ReadonlyWorld

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

    init(world: ReadonlyWorld) {
        self.world = world
        tileMenu = TileMenu(settings: world.settings)
        tileMenu.didSelect.subscribe(observer: self) {
            self.select(actionMode: .place)
        }
    }

    func select(selectMode: EditSelectMode) {
        editSelection = .none(mode: selectMode)
    }

    func select(actionMode: EditActionMode) {
        if actionMode != .place {
            tileMenu.openLayer = nil
        }

        editAction = EditAction(mode: actionMode, selectedPositions: editAction.selectedPositions)
        editSelection = editSelection.endedOrCancelled
        performCurrentActionIfNecessaryOnSelect(selectedPositions: editAction.selectedPositions)
    }
    
    //region touch input adapting
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        if let touchPos = getTouchPos(touches: event?.allTouches, camera: camera, container: container) {
            afterTouchDown(touchPos: touchPos)
        } else {
            afterCancel()
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        if let touchPos = getTouchPos(touches: event?.allTouches, camera: camera, container: container) {
            afterTouchMove(touchPos: touchPos)
        } else {
            afterCancel()
        }

    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        if let touchPos = getTouchPos(touches: event?.allTouches, camera: camera, container: container) {
            afterTouchUp(touchPos: touchPos)
        } else {
            afterCancel()
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, camera: Camera, container: SKScene) {
        afterCancel()
    }

    /// If there is one touch, returns the corresponding TouchPos. Otherwise returns nil
    private func getTouchPos(touches: Set<UITouch>?, camera: Camera, container: SKScene) -> TouchPos? {
        if let touches = touches,
           touches.count == 1 {
            return TouchPos(uiTouch: touches.randomElement()!, camera: camera, settings: world.settings, container: container)
        } else {
            return nil
        }
    }
    //endregion

    //region touch handling
    func afterTouchDown(touchPos: TouchPos) {
        if inspector != nil {
            dismissInspector()
            editAction = .inspect(selectedPositions: [])
        }

        if editAction.mode.requiresSelection && editAction.selectedPositions.isEmpty {
            // Move initiated with no selection, so we instant-select
            let selectedPositions = editSelection.tryInstantSelect(touchPos: touchPos, world: world)
            switch editAction.mode {
            case .move:
                // Perform a move with these tiles - select them and then perform a move
                let nextEditMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
                editAction = .move(selectedPositions: selectedPositions, state: nextEditMoveState)
            case .inspect:
                // Inspect these tiles
                editAction = .inspect(selectedPositions: selectedPositions)
            case .place, .remove, .select:
                fatalError("unhandled move which requires selection: \(editAction.mode)")
            }
        } else {
            if hasEditMoveState {
                // Perform a move with the selected tiles
                editMoveState = editMoveState.afterTouchDown(firstTouchPos: touchPos)
            } else {
                // Perform a select
                editSelection = editSelection.afterTouchDown(firstTouchPos: touchPos)
            }
        }
    }

    func afterTouchMove(touchPos: TouchPos) {
        if hasEditMoveState && editMoveState.isStarted {
            editMoveState = editMoveState.afterTouchMove(nextTouchPos: touchPos)
        } else if !hasEditMoveState && !editSelection.isNone {
            editSelection = editSelection.afterTouchMove(nextTouchPos: touchPos)
        }
    }

    func afterTouchUp(touchPos: TouchPos) {
        if hasEditMoveState && editMoveState.isStarted {
            let distanceMoved = editMoveState.distanceMovedAfterTouchUp(finalTouchPos: touchPos)
            delegate?.performMoveAction(selectedPositions: editAction.selectedPositions, distanceMoved: distanceMoved)
            editAction = .move(selectedPositions: [], state: .notStarted)
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
    //endregion

    //region actions
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

    func performCurrentActionIfNecessaryOnSelect(selectedPositions: Set<WorldTilePos3D>) {
        switch editAction.mode {
        case .place:
            delegate?.performPlaceAction(selectedPositions: selectedPositions, selectedTileType: selectedTileType)
        case .remove:
            delegate?.performRemoveAction(selectedPositions: selectedPositions)
        case .inspect:
            presentInspector(selectedPositions: selectedPositions)
        case .move, .select:
            // Not necessary on select
            break
        }
    }

    func presentInspector(selectedPositions: Set<WorldTilePos3D>) {
        assert(editAction.mode == EditActionMode.inspect)
        inspector = Inspector(positions: selectedPositions, delegate: delegate, world: world)
    }

    func dismissInspector() {
        inspector = nil
    }
    //endregion
}
