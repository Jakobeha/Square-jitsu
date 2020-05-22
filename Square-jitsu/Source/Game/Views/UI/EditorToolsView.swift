//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsView: UXCompoundView {
    private let editor: Editor

    private let editorToolsTopView: EditorToolsTopView
    private let editorToolsSideView: EditorToolsSideView

    init(editor: Editor) {
        self.editor = editor
        editorToolsTopView = EditorToolsTopView(editorTools: editor.tools)
        editorToolsSideView = EditorToolsSideView(editorTools: editor.tools, undoManager: editor.undoManager)
    }
    
    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return Button(textureName: "UI/Pause") {
                self.editor.state = .editing
                self.regenerateBody()
            }
        case .editing:
            return HStack([
                VStack([
                    Button(textureName: "UI/Play") {
                        self.editor.state = .playing
                        self.regenerateBody()
                    },
                    editorToolsTopView
                ]),
                editorToolsSideView
            ])
        }
    }
}
