//
// Created by Jakob Hain on 5/27/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditMoveView: UXView {
    private let editor: Editor

    let node: SKNode = SKNode()
    // TODO: Make an SKEffectNode and add a shadow effect
    private let tileViewsNode: SKNode = SKNode()
    private var tileViews: [TileView] = []

    private var hasTileViews: Bool { !tileViews.isEmpty }

    private var sceneSize: CGSize = CGSize.zero
    var size: CGSize { sceneSize }

    init(editor: Editor) {
        self.editor = editor

        node.addChild(tileViewsNode)

        editor.tools.didChangeEditAction.subscribe(observer: self, priority: .view, handler: updateMovedTileViews)
        editor.editorCamera.didChange.subscribe(observer: self, priority: .view, handler: updateNodePositionForCameraChange)
    }

    private func updateMovedTileViews() {
        switch editor.tools.editAction {
        case .move(let selectedPositions, let state):
            updateMovedTileViews(selectedPositions: selectedPositions, state: state)
        case .copy(let selectedPositions, let state):
            updateMovedTileViews(selectedPositions: selectedPositions, state: state)
        default:
            removeMovedTileViewsIfNecessary()
        }
    }

    private func updateMovedTileViews(selectedPositions: Set<WorldTilePos3D>, state: EditMoveState) {
        switch state {
        case .notStarted:
            removeMovedTileViewsIfNecessary()
        case .inProgress(let start, let end):
            addMovedTileViewsIfNecessary(positions: selectedPositions)
            updateMovedTileViewPositions(startTouchPos: start, endTouchPos: end)
        }
    }

    private func removeMovedTileViewsIfNecessary() {
        if hasTileViews {
            for tileView in tileViews {
                tileView.removeFromParent()
            }
            tileViews.removeAll()
        }
    }

    private func addMovedTileViewsIfNecessary(positions: Set<WorldTilePos3D>) {
        if hasTileViews {
            assert(tileViews.count == positions.count, "unexpected change in moved tile positions, didn't implement handling this")
        } else {
            for pos3D in positions {
                let tileType = editor.editableWorld.world[pos3D]
                let tileView = TileView(world: editor.editableWorld.world, pos3D: pos3D, tileType: tileType, coordinates: .world)
                tileView.placeIn(parent: tileViewsNode)
                tileViews.append(tileView)
            }
        }
    }

    private func updateMovedTileViewPositions(startTouchPos: TouchPos, endTouchPos: TouchPos) {
        let offsetFromMove = (endTouchPos.worldScreenPos - startTouchPos.worldScreenPos) * editor.settings.tileViewWidthHeight
        tileViewsNode.position = offsetFromMove
    }

    private func updateNodePositionForCameraChange() {
        editor.editorCamera.inverseTransformUX(rootNode: node)
    }

    func set(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
}
