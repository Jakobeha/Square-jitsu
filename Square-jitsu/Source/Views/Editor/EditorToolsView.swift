//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsView: UXCompoundView {
    private let editor: Editor

    private let overlayContainerView: OverlayContainerView
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

        overlayContainerView = OverlayContainerView(overlayContainer: editor.overlays)
        inspectorContainerView = InspectorContainerView(editorTools: editor.tools, world: editor.editableWorld.world, worldUrl: editor.editableWorld.worldUrl)
        editMoveView = EditMoveView(editor: editor)
        editSelectionView = EditSelectionView(editor: editor)
        actionView = EditorToolsActionView(editorTools: editor.tools, settings: editor.settings)
        selectModeView = EditorToolsSelectModeView(editorTools: editor.tools)
        gameplayControlView = GameplayControlView(editor: editor)
        undoView = UndoView(undoManager: editor.undoManager)
        gridView = GridView(camera: editor.editorCamera, settings: editor.settings)
        super.init()

        editor.didChangeState.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        switch editor.state {
        case .playing:
            return ZStack([
                overlayContainerView,
                gameplayControlView
            ])
        case .editing:
            return ZStack([
                overlayContainerView,
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
                    Button(owner: self, textureName: "UI/Settings", size: .small) { (self) in
                        print("TODO")
                    },
                    Button(owner: self, textureName: "UI/Save", size: .small) { (self) in
                        self.editor.editableWorld.saveToDisk()
                    },
                    Button(owner: self, textureName: "UI/Quit", size: .small) { (self) in
                        self.editor.conduit.quit()
                    }
                ]),
                gridView
            ])
        }
    }
}
