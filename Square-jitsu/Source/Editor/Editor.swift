//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Editor model class
class Editor: EditorToolsDelegate {
    let tools: EditorTools = EditorTools()
    let editableWorld: EditableWorld
    let editorCamera: FreeCamera = FreeCamera()
    var state: EditorState = .editing {
        didSet { _didChangeState.publish() }
    }
    let undoManager: UndoManager

    private let _didChangeState: Publisher<()> = Publisher()
    var didChangeState: Observable<()> { Observable(publisher: _didChangeState) }

    init(editableWorld: EditableWorld) {
        self.editableWorld = editableWorld
        self.undoManager = UndoManager()
        tools.delegate = self
        tools.world = editableWorld.world
    }

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
}
