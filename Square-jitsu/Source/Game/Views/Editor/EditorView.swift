//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorView: NodeView<SKNode> {
    private let editor: Editor

    private let worldCameraView: CameraView

    init(editor: Editor, sceneSize: CGSize) {
        self.editor = editor

        let editorToolsView = EditorToolsView(editor: editor, sceneSize: sceneSize)
        let editorUiView = UXTopLevelView(child: editorToolsView, sceneSize: sceneSize)

        let worldView = WorldView(world: editor.editableWorld.world)
        worldCameraView = CameraView(camera: editor.currentCamera, child: worldView)

        super.init(node: SKNode())
        editorUiView.placeIn(parent: node)
        worldCameraView.placeIn(parent: node)
        // So that editor tools are on top of world
        editorUiView.zPosition = TileType.zPositionUpperBound
        worldCameraView.node.zPosition = 0

        editor.didChangeState.subscribe(observer: self, handler: changeCamera)
    }

    private func changeCamera() {
        worldCameraView.camera = editor.currentCamera
    }
}
