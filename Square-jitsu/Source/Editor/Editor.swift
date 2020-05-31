//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Editor model class
class Editor: EditorToolsDelegate {
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
    convenience init(worldDocument: WorldDocument, userSettings: UserSettings) {
        let worldFile = worldDocument.file!
        let editableWorld = EditableWorld(worldFile: worldFile, userSettings: userSettings)

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

        let tilesToMove = selectedPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }
        let originalTiles = affectedPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }

        if !isCopy {
            for oldPosition in selectedPositions {
                editableWorld[oldPosition] = TileType.air
            }
        }

        for tileToMove in tilesToMove {
            let newPosition = tileToMove.position.pos + distanceMoved
            let typeToMove = tileToMove.type

            editableWorld.createTile(pos: newPosition, type: typeToMove)
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
        let originalTiles = possibleChangedPositions.map { pos3D in
            TileAtPosition(type: editableWorld[pos3D], position: pos3D)
        }

        for position2D in selectedPositions2D {
            editableWorld.createTile(pos: position2D, type: selectedTileType)
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>) {
        let originalTiles = selectedPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }
        
        for position in selectedPositions {
            editableWorld[position] = TileType.air
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    private func revertAction(originalTiles: [TileAtPosition]) {
        let nowOriginalTiles: [TileAtPosition] = originalTiles.map { originalTile in
            let position = originalTile.position
            return TileAtPosition(type: editableWorld[position], position: position)
        }

        for originalTile in originalTiles {
            let type = originalTile.type
            let position = originalTile.position
            editableWorld[position] = type
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
            newTileType.orientation = TileOrientation(side: side)
            editableWorld[tileAtPosition.position] = newTileType
        }
    }

    func setInitialTurretDirections(to initialTurretDirection: Angle, positions: Set<WorldTilePos3D>) {
        for pos3D in positions {
            let metadata = editableWorld.getMetadataAt(pos3D: pos3D)! as! TurretMetadata
            metadata.initialTurretDirectionRelativeToAnchor = initialTurretDirection
        }
    }
    // endregion

    private func didPerformAction() {
        editableWorld.world.runActions()
    }
    // endregion

    // region touch forwarding
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        switch state {
        case .playing:
            editableWorld.world.playerInput.tracker.touchesBegan(touches, with: event, container: container)
        case .editing:
            tools.touchesBegan(touches, with: event, camera: currentCamera, container: container)
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        switch state {
        case .playing:
            editableWorld.world.playerInput.tracker.touchesMoved(touches, with: event, container: container)
        case .editing:
            tools.touchesMoved(touches, with: event, camera: currentCamera, container: container)
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        switch state {
        case .playing:
            editableWorld.world.playerInput.tracker.touchesEnded(touches, with: event, container: container)
        case .editing:
            tools.touchesEnded(touches, with: event, camera: currentCamera, container: container)
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, container: SKScene) {
        switch state {
        case .playing:
            editableWorld.world.playerInput.tracker.touchesCancelled(touches, with: event, container: container)
        case .editing:
            tools.touchesCancelled(touches, with: event, camera: currentCamera, container: container)
        }
    }
    // endregion
}
