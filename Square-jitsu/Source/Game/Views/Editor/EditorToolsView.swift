//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsView: UXCompoundView {
    private let editor: Editor

    private let inspectorContainerView: InspectorContainerView
    private let editMoveView: EditMoveView
    private let editSelectionView: EditSelectionView
    private let actionView: EditorToolsActionView
    private let selectModeView: EditorToolsSelectModeView
    private let gameplayControlView: GameplayControlView
    private let undoView: UndoView
    private let gridView: GridView

    init(editor: Editor) {
        self.editor = editor

        inspectorContainerView = InspectorContainerView(editorTools: editor.tools)
        editMoveView = EditMoveView(editor: editor)
        editSelectionView = EditSelectionView(editor: editor)
        actionView = EditorToolsActionView(editorTools: editor.tools, settings: editor.editableWorld.world.settings)
        selectModeView = EditorToolsSelectModeView(editorTools: editor.tools)
        gameplayControlView = GameplayControlView(editor: editor)
        undoView = UndoView(undoManager: editor.undoManager)
        gridView = GridView(camera: editor.editorCamera, settings: editor.editableWorld.world.settings)
        super.init()

        editor.didChangeState.subscribe(observer: self, priority: ObservablePriority.view, handler: regenerateBody)
    }
    
    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return gameplayControlView
        case .editing:
            return ZStack([
                inspectorContainerView,
                editMoveView,
                editSelectionView,
                VStack([
                    HStack([
                        gameplayControlView,
                        VStack([
                            actionView,
                            selectModeView,
                            undoView
                        ])
                    ]),
                    Button(textureName: "UI/Settings", size: .small) {
                        print("TODO")
                    },
                    Button(textureName: "UI/Save", size: .small) { 
                        self.editor.editableWorld.saveToDisk()
                    },
                    Button(textureName: "UI/Quit", size: .small) { 
                        print("TODO") 
                    }
                ]),
                gridView
            ])
        }
    }
}
