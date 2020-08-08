//
// Created by Jakob Hain on 5/23/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditSelectionView: UXView {
    private static let fillColor: SKColor = SKColor(white: 1, alpha: 0.125)
    private static let currentSelectionStrokeColor: SKColor = SKColor(hue: 0.15, saturation: 1, brightness: 1, alpha: 1)
    private static let interactedStrokeColor: SKColor = SKColor(hue: 7.0 / 16, saturation: 1, brightness: 1, alpha: 1)
    private static let lineWidth: CGFloat = 2
    private static let glowWidth: CGFloat = 4

    private let editor: Editor

    let node: SKNode = SKNode()
    private let currentSelectionNode: SKShapeNode
    private let interactedNode: SKShapeNode

    private var sceneSize: CGSize = CGSize.zero
    var size: CGSize { sceneSize }

    init(editor: Editor) {
        self.editor = editor

        currentSelectionNode = SKShapeNode()
        interactedNode = SKShapeNode()
        currentSelectionNode.fillColor = EditSelectionView.fillColor
        interactedNode.fillColor = EditSelectionView.fillColor
        currentSelectionNode.strokeColor = EditSelectionView.currentSelectionStrokeColor
        interactedNode.strokeColor = EditSelectionView.interactedStrokeColor
        currentSelectionNode.lineWidth = EditSelectionView.lineWidth
        interactedNode.lineWidth = EditSelectionView.lineWidth
        currentSelectionNode.glowWidth = EditSelectionView.glowWidth
        interactedNode.glowWidth = EditSelectionView.glowWidth
        // current selection over past selection
        currentSelectionNode.zPosition = 1
        interactedNode.zPosition = 0
        node.addChild(currentSelectionNode)
        node.addChild(interactedNode)

        updateCurrentSelectionNodePath()
        updateInteractedNodePath()
        updateNodePositionForCameraChange()
        editor.editorCamera.didChange.subscribe(observer: self, priority: .view) { (self) in
            self.updateNodePositionForCameraChange()
        }
        editor.tools.didChangeEditAction.subscribe(observer: self, priority: .view) { (self) in
            self.updateInteractedNodePath()
        }
        editor.tools.didChangeInspector.subscribe(observer: self, priority: .view) { (self) in
            self.updateInteractedNodePath()
        }
        editor.tools.didChangeEditSelection.subscribe(observer: self, priority: .view) { (self) in
            self.updateCurrentSelectionNodePath()
        }
    }

    private func updateNodePositionForCameraChange() {
        editor.editorCamera.inverseTransformUX(rootNode: node)
    }

    private func updateCurrentSelectionNodePath() {
        let editSelection = editor.tools.editSelection
        let selectedPositions3D = editSelection.getSelectedPositions(world: editor.editableWorld.world)
        let selectedPositions = Set(selectedPositions3D.map { pos3D in pos3D.pos })
        currentSelectionNode.path = editor.settings.generatePathOfShapeMadeBy(positions: selectedPositions)
    }

    private func updateInteractedNodePath() {
        let interactedPositions3D = editor.tools.interactedTiles
        let interactedPositions = Set(interactedPositions3D.map { pos3D in pos3D.pos })
        interactedNode.path = editor.settings.generatePathOfShapeMadeBy(positions: interactedPositions)
    }

    func set(scene: SJScene) {
        sceneSize = scene.size
    }
}
