//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorView: NodeView<SKNode> {
    private let editor: Editor

    private let editorUiView: UXTopLevelView
    private let worldCameraView: CameraView
    private let glossMaskView: CameraView

    init(editor: Editor, scene: SJScene) {
        self.editor = editor

        let editorToolsView = EditorToolsView(editor: editor)
        editorUiView = UXTopLevelView(child: editorToolsView, scene: scene)

        let glossNode = SKCropNode()
        let glossMaskNode = SKNode()
        let glossMaskChildView = NodeView(node: glossMaskNode)
        let glossSpriteNode = SKSpriteNode(texture: editor.settings.glossTexture, size: scene.size)
        glossMaskView = CameraView(camera: editor.currentCamera, child: glossMaskChildView)
        glossSpriteNode.anchorPoint = CGPoint.zero
        glossNode.isUserInteractionEnabled = false
        glossNode.maskNode = glossMaskView.node
        glossNode.addChild(glossSpriteNode)

        let worldView = WorldView(world: editor.editableWorld.world, glossMaskNode: glossMaskNode)
        worldCameraView = CameraView(camera: editor.currentCamera, child: worldView)

        super.init(node: SKNode())
        editorUiView.placeIn(parent: node)
        node.addChild(glossNode)
        worldCameraView.placeIn(parent: node)
        // So that editor tools are on top the gloss, which is on top of the world
        editorUiView.zPosition = TileType.zPositionUpperBound + 1
        glossNode.zPosition = TileType.zPositionUpperBound
        worldCameraView.node.zPosition = 0

        editor.didChangeState.subscribe(observer: self, priority: .view) { (self) in
            self.changeCamera()
        }
    }

    private func changeCamera() {
        worldCameraView.camera = editor.currentCamera
        glossMaskView.camera = editor.currentCamera
    }
}
