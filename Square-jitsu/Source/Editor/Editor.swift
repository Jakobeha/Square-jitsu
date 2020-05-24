//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Editor model class
class Editor: EditorToolsDelegate {
    let editableWorld: EditableWorld
    let tools: EditorTools
    let editorCamera: Camera = Camera()
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

    private let _didChangeState: Publisher<()> = Publisher()
    var didChangeState: Observable<()> { Observable(publisher: _didChangeState) }

    /// Creates an editable world from the document and settings, and an editor for it
    convenience init(worldDocument: WorldDocument, userSettings: UserSettings) throws {
        let worldFile = try worldDocument.getFile()
        let editableWorld = EditableWorld(worldFile: worldFile, userSettings: userSettings)

        self.init(editableWorld: editableWorld, undoManager: worldDocument.undoManager)
    }
    
    init(editableWorld: EditableWorld, undoManager: UndoManager) {
        self.editableWorld = editableWorld
        tools = EditorTools(world: editableWorld.world)
        self.undoManager = undoManager

        tools.delegate = self
    }

    //region actions
    func performMoveAction(selectedPositions: Set<WorldTilePos3D>, distanceMoved: RelativePos) {
        let positionsAfterMove = selectedPositions.map { selectedPosition in
            selectedPosition + distanceMoved
        }
        let allPositions = selectedPositions.union(positionsAfterMove)

        let tilesToMove = selectedPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }
        let originalTiles = allPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }

        for oldPosition in selectedPositions {
            editableWorld[oldPosition] = TileType.air
        }

        for tileToMove in tilesToMove {
            let newPosition = tileToMove.position + distanceMoved
            let typeToMove = tileToMove.type

            editableWorld[newPosition] = typeToMove
        }

        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: originalTiles)
        }
    }

    func performPlaceAction(selectedPositions: Set<WorldTilePos3D>, selectedTileType: TileType) {
        let originalTiles = selectedPositions.map { position in
            TileAtPosition(type: editableWorld[position], position: position)
        }

        for position in selectedPositions {
            editableWorld[position] = selectedTileType
        }

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

        undoManager.registerUndo(withTarget: self) { this in
            this.revertAction(originalTiles: nowOriginalTiles)
        }
    }
    //endregion

    //region touch forwarding
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
    //endregion
}
