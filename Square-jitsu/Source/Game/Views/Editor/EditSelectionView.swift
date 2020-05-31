//
// Created by Jakob Hain on 5/23/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditSelectionView: UXView {
    private static let fillColor: SKColor = SKColor(white: 1, alpha: 0.125)
    private static let currentSelectionStrokeColor: SKColor = SKColor(hue: 0.15, saturation: 1, brightness: 1, alpha: 1)
    private static let pastSelectionStrokeColor: SKColor = SKColor(hue: 7.0 / 16, saturation: 1, brightness: 1, alpha: 1)
    private static let lineWidth: CGFloat = 2
    private static let glowWidth: CGFloat = 4

    private let editor: Editor

    let node: SKNode = SKNode()
    private let currentSelectionNode: SKShapeNode
    private let pastSelectionNode: SKShapeNode

    private var sceneSize: CGSize = CGSize.zero
    var size: CGSize { sceneSize }

    init(editor: Editor) {
        self.editor = editor

        currentSelectionNode = SKShapeNode()
        pastSelectionNode = SKShapeNode()
        currentSelectionNode.fillColor = EditSelectionView.fillColor
        pastSelectionNode.fillColor = EditSelectionView.fillColor
        currentSelectionNode.strokeColor = EditSelectionView.currentSelectionStrokeColor
        pastSelectionNode.strokeColor = EditSelectionView.pastSelectionStrokeColor
        currentSelectionNode.lineWidth = EditSelectionView.lineWidth
        pastSelectionNode.lineWidth = EditSelectionView.lineWidth
        currentSelectionNode.glowWidth = EditSelectionView.glowWidth
        pastSelectionNode.glowWidth = EditSelectionView.glowWidth
        // current selection over past selection
        currentSelectionNode.zPosition = 1
        pastSelectionNode.zPosition = 0
        node.addChild(currentSelectionNode)
        node.addChild(pastSelectionNode)

        updateCurrentSelectionNodePath()
        updatePastSelectionNodePath()
        updateNodePositionForCameraChange()
        editor.editorCamera.didChange.subscribe(observer: self, priority: ObservablePriority.view) {
            self.updateNodePositionForCameraChange()
        }
        editor.tools.didChangeEditAction.subscribe(observer: self, priority: ObservablePriority.view) {
            self.updatePastSelectionNodePath()
        }
        editor.tools.didChangeEditSelection.subscribe(observer: self, priority: ObservablePriority.view) {
            self.updateCurrentSelectionNodePath()
        }
    }

    private func updateNodePositionForCameraChange() {
        editor.editorCamera.inverseTransformUX(rootNode: node)
    }

    private func updateCurrentSelectionNodePath() {
        let editSelection = editor.tools.editSelection
        let selectedPositions3D = editSelection.isNone ? [] : editSelection.getSelectedPositions(world: editor.editableWorld.world)
        let selectedPositions = Set(selectedPositions3D.map { worldTilePos3d in worldTilePos3d.pos })
        currentSelectionNode.path = WorldTilePos.pathOfShapeMadeBy(positions: selectedPositions, scale: editor.settings.tileViewWidthHeight, offset: CGPoint.zero)
    }

    private func updatePastSelectionNodePath() {
        let selectedPositions3D = editor.tools.editAction.selectedPositions
        let selectedPositions = Set(selectedPositions3D.map { worldTilePos3d in worldTilePos3d.pos })
        pastSelectionNode.path = WorldTilePos.pathOfShapeMadeBy(positions: selectedPositions, scale: editor.settings.tileViewWidthHeight, offset: CGPoint.zero)
    }

    func set(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
}
