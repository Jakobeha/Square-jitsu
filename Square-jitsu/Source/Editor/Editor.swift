//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Editor model class
class Editor: EditorToolsDelegate {
    let overlays: OverlayContainer = OverlayContainer()
    let editableWorld: EditableWorld
    let tools: EditorTools
    let editorCamera: Camera
    var state: EditorState = .editing {
        didSet { _didChangeState.publish() }
    }
    let undoManager: UndoManager

    var currentCamera: Camera {
        switch state {
        case .playing:
            return editableWorld.world.playerCamera
        case .editing:
            return editorCamera
        }
    }

    var settings: WorldSettings { editableWorld.settings }

    private let _didChangeState: Publisher<()> = Publisher()
    var didChangeState: Observable<()> { Observable(publisher: _didChangeState) }

    /// Creates an editable world from the document and settings, and an editor for it
    convenience init(worldDocument: WorldDocument, userSettings: UserSettings, conduit: WorldConduit?) {
        let worldFile = worldDocument.file!
        let editableWorld = EditableWorld(worldFile: worldFile, userSettings: userSettings, conduit: conduit)

        self.init(editableWorld: editableWorld, undoManager: worldDocument.undoManager, userSettings: userSettings)
    }
    
    init(editableWorld: EditableWorld, undoManager: UndoManager, userSettings: UserSettings) {
        self.editableWorld = editableWorld
        editorCamera = Camera(userSettings: userSettings)
        tools = EditorTools(world: editableWorld, editorCamera: editorCamera, undoManager: undoManager, userSettings: userSettings)
        self.undoManager = undoManager
        
        editorCamera.world = editableWorld.world
        tools.delegate = self
    }

    // region actions
    func performMoveAction(selectedPositions: Set<WorldTilePos3D>, distanceMoved: RelativePos, isCopy: Bool) {
        let positionsAfterMove = Set(selectedPositions.map { selectedPosition in
            selectedPosition.pos + distanceMoved
        })
        let allLayersAtPositionsAfterMove = Set(positionsAfterMove.flatMap { pos in
            (0..<Chunk.numLayers).map { layer in WorldTilePos3D(pos: pos, layer: layer) }
        })
        let affectedPositions = isCopy ? allLayersAtPositionsAfterMove : selectedPositions.union(allLayersAtPositionsAfterMove)

        let tilesToMove = selectedPositions.map(editableWorld.getTileAt)
        let originalTiles = affectedPositions.map(editableWorld.getTileAt)

        if !isCopy {
            for oldPosition in selectedPositions {
                editableWorld[oldPosition] = TileType.air
            }
        }

        for tileToMove in tilesToMove {
            let newPosition = tileToMove.position.pos + distanceMoved
            let typeToMove = tileToMove.type

            editableWorld.forceCreateTile(pos: newPosition, type: typeToMove)
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    func performPlaceAction(selectedPositions2D: Set<WorldTilePos>, selectedTileType: TileType) {
        // Not all the original tiles will definitely be changed, since we use 2D positions,
        // but all of them could be changed, so we reuse originalTiles
        let possibleChangedPositions = selectedPositions2D.flatMap { pos2D in
            (0..<Chunk.numLayers).map { layer in
                WorldTilePos3D(pos: pos2D, layer: layer)
            }
        }
        let originalTiles = possibleChangedPositions.map(editableWorld.getTileAt)

        for position2D in selectedPositions2D {
            editableWorld.forceCreateTile(pos: position2D, type: selectedTileType)
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>) {
        let originalTiles = selectedPositions.map(editableWorld.getTileAt)
        
        for position in selectedPositions {
            editableWorld[position] = TileType.air
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    private func revertAction(originalTiles: [TileAtPosition]) {
        let nowOriginalTiles: [TileAtPosition] = originalTiles.map(editableWorld.getUpdatedTileAtPosition)

        for originalTile in originalTiles {
            editableWorld.setTileAtPositionTo(originalTile)
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: nowOriginalTiles)
        }
    }

    // region inspector actions
    func connectTilesToSide(tiles: [TileAtPosition], side: Side) {
        for tileAtPosition in tiles {
            var newTileType = tileAtPosition.type
            newTileType.orientation = addSideToOrientationInType(type: newTileType, side: side)
            editableWorld[tileAtPosition.position] = newTileType
        }
    }

    private func addSideToOrientationInType(type: TileType, side: Side) -> TileOrientation {
        switch settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionToCorner:
            fatalError("orientation isn't side-based")
        case .directionAdjacentToSolid:
            return TileOrientation(side: side)
        case .atBackgroundBorder, .atSolidBorder:
            var orientation = type.orientation
            orientation.asSideSet.insert(side.toSet)
            return orientation
        }
    }

    func disconnectTilesToSide(tiles: [TileAtPosition], side: Side) {
        for tileAtPosition in tiles {
            var newTileType = tileAtPosition.type
            newTileType.orientation = tryRemoveSideToOrientationInType(type: newTileType, side: side)
            editableWorld[tileAtPosition.position] = newTileType
        }
    }

    private func tryRemoveSideToOrientationInType(type: TileType, side: Side) -> TileOrientation {
        switch settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionToCorner:
            fatalError("orientation isn't side-based")
        case .directionAdjacentToSolid:
            // Can't remove because there is only one side
            return type.orientation
        case .atBackgroundBorder, .atSolidBorder:
            var orientation = type.orientation
            orientation.asSideSet.remove(side.toSet)
            return orientation
        }
    }

    func connectTilesToCorner(tiles: [TileAtPosition], corner: Corner) {
        for tileAtPosition in tiles {
            var newTileType = tileAtPosition.type
            newTileType.orientation = addCornerToOrientationInType(type: newTileType, corner: corner)
            editableWorld[tileAtPosition.position] = newTileType
        }
    }

    private func addCornerToOrientationInType(type: TileType, corner: Corner) -> TileOrientation {
        switch settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionAdjacentToSolid, .atBackgroundBorder, .atSolidBorder:
            fatalError("orientation isn't corner-based")
        case .directionToCorner:
            return TileOrientation(corner: corner)
        }
    }

    func disconnectTilesToCorner(tiles: [TileAtPosition], corner: Corner) {
        for tileAtPosition in tiles {
            var newTileType = tileAtPosition.type
            newTileType.orientation = tryRemoveCornerToOrientationInType(type: newTileType, corner: corner)
            editableWorld[tileAtPosition.position] = newTileType
        }
    }

    private func tryRemoveCornerToOrientationInType(type: TileType, corner: Corner) -> TileOrientation {
        switch settings.tileOrientationMeanings[type] ?? .unused {
        case .unused, .directionAdjacentToSolid, .atBackgroundBorder, .atSolidBorder:
            fatalError("orientation isn't corner-based")
        case .directionToCorner:
            // Can't remove because there is only one side
            return type.orientation
        }
    }

    func setInitialTurretDirections(to initialTurretDirectionsAndPositions: Zip2Sequence<[Angle], [WorldTilePos3D]>) {
        for (initialTurretDirection, pos3D) in initialTurretDirectionsAndPositions {
            var metadata = editableWorld.getMetadataAt(pos3D: pos3D)! as! TurretMetadata
            metadata.initialTurretDirectionRelativeToAnchor = initialTurretDirection
            editableWorld.setMetadataAt(pos3D: pos3D, to: metadata)
        }
    }
    // endregion

    private func didPerformAction() {
        editableWorld.world.runActions()
    }
    // endregion

    // region touch forwarding
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        overlays.touchesBegan(touches, with: event, container: container)
        if !overlays.preventTouchPropagation {
            switch state {
            case .playing:
                editableWorld.world.playerInput.tracker.touchesBegan(touches, with: event, container: container)
            case .editing:
                tools.touchesBegan(touches, with: event, camera: currentCamera, container: container)
            }
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        overlays.touchesMoved(touches, with: event, container: container)
        if !overlays.preventTouchPropagation {
            switch state {
            case .playing:
                editableWorld.world.playerInput.tracker.touchesMoved(touches, with: event, container: container)
            case .editing:
                tools.touchesMoved(touches, with: event, camera: currentCamera, container: container)
            }
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        overlays.touchesEnded(touches, with: event, container: container)
        if !overlays.preventTouchPropagation {
            switch state {
            case .playing:
                editableWorld.world.playerInput.tracker.touchesEnded(touches, with: event, container: container)
            case .editing:
                tools.touchesEnded(touches, with: event, camera: currentCamera, container: container)
            }
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        overlays.touchesCancelled(touches, with: event, container: container)
        if !overlays.preventTouchPropagation {
            switch state {
            case .playing:
                editableWorld.world.playerInput.tracker.touchesCancelled(touches, with: event, container: container)
            case .editing:
                tools.touchesCancelled(touches, with: event, camera: currentCamera, container: container)
            }
        }
    }
    // endregion

    func tick() {
        switch state {
        case .editing:
            tools.tick()
        case .playing:
            editableWorld.world.tick()
        }
    }
}
