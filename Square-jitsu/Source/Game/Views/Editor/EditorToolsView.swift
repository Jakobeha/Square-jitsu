//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsView: UXCompoundView {
    private let editor: Editor

    private let editorToolsTopView: EditorToolsTopView
    private let editorToolsSideView: EditorToolsSideView
    private let editSelectionView: EditSelectionView

    init(editor: Editor) {
        self.editor = editor
        editorToolsTopView = EditorToolsTopView(editorTools: editor.tools)
        editorToolsSideView = EditorToolsSideView(editorTools: editor.tools, undoManager: editor.undoManager)
        editSelectionView = EditSelectionView(editor: editor)
    }
    
    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return Button(textureName: "UI/Pause") {
                self.editor.state = .editing
                self.regenerateBody()
            }
        case .editing:
            return ZStack([
                editSelectionView,
                HStack([
                    VStack([
                        Button(textureName: "UI/Play") {
                            self.editor.state = .playing
                            self.regenerateBody()
                        },
                        editorToolsSideView,
                        Button(textureName: "UI/Save", size: .small) { 
                            self.editor.editableWorld.saveToDisk()
                        },
                        Button(textureName: "UI/Quit", size: .small) { 
                            print("TODO") 
                        }
                    ]),
                    editorToolsTopView
                ])
            ])
        }
    }
}
