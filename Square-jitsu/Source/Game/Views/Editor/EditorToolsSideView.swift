//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsSideView: UXCompoundView {
    private let editorTools: EditorTools

    private let selectModeView: EditorToolsSelectModeView
    private let undoView: UndoView

    init(editorTools: EditorTools, undoManager: UndoManager) {
        self.editorTools = editorTools
        selectModeView = EditorToolsSelectModeView(editorTools: editorTools)
        undoView = UndoView(undoManager: undoManager)
    }

    override func newBody() -> UXView {
        VStack([
            ReLayout(selectModeView, width: ButtonSize.medium.sideLength),
            ReLayout(undoView, width: ButtonSize.medium.sideLength),
            Button(textureName: "UI/Settings", size: .small) { 
                print("TODO")
            }
        ])
    }
}
