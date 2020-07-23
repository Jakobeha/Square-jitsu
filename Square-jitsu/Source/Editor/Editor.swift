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
        didSet {
            editableWorld.world.showEditingIndicators = state.showEditingIndicators
            _didChangeState.publish()
        }
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
    var conduit: WorldConduit { editableWorld.world.conduit }

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

        editableWorld.world.showEditingIndicators = true
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
        undoManager.registerUndo(withTarget: self) { (self) in
            self.overwrite(tiles: originalTiles)
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
        undoManager.registerUndo(withTarget: self) { (self) in
            self.overwrite(tiles: originalTiles)
        }
    }

    func performRemoveAction(selectedPositions: Set<WorldTilePos3D>) {
        let originalTiles = selectedPositions.map(editableWorld.getTileAt)
        
        for position in selectedPositions {
            editableWorld[position] = TileType.air
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { (self) in
            self.overwrite(tiles: originalTiles)
        }
    }

    func overwrite(tiles: [TileAtPosition]) {
        let originalTiles: [TileAtPosition] = tiles.map(editableWorld.getUpdatedTileAtPosition)

        for originalTile in tiles {
            editableWorld.setTileAtPositionTo(originalTile)
        }

        didPerformAction()
        undoManager.registerUndo(withTarget: self) { (self) in
            self.overwrite(tiles: originalTiles)
        }
    }

    func setInitialTurretDirections(to initialTurretDirectionsAndPositions: Zip2Sequence<[Angle], [WorldTilePos3D]>) {
        for (initialTurretDirection, pos3D) in initialTurretDirectionsAndPositions {
            var metadata = editableWorld.getMetadataAt(pos3D: pos3D)! as! TurretMetadata
            metadata.initialTurretDirectionRelativeToAnchor = initialTurretDirection
            editableWorld.setMetadataAt(pos3D: pos3D, to: metadata)
        }
    }
    
    func setMetadataOf(tiles: [TileAtPosition], metadata: TileMetadata) {
        for tileAtPosition in tiles {
            let pos3D = tileAtPosition.position
            editableWorld.setMetadataAt(pos3D: pos3D, to: metadata)
        }
    }

    private func didPerformAction() {
        editableWorld.world.runActions()
        tools.inspector?.reload()
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
