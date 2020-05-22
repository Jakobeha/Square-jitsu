//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsSideView: UXCompoundView {
    private let editorTools: EditorTools

    private let undoView: UndoView

    init(editorTools: EditorTools, undoManager: UndoManager) {
        self.editorTools = editorTools
        undoView = UndoView(undoManager: undoManager)
    }

    override func newBody() -> UXView {
        VStack([
            HStack([
                Button(textureName: "UI/SelectRect") { print("TODO") }, 
                Button(textureName: "UI/SelectPrecision") { print("TODO") }, 
                Button(textureName: "UI/SelectFreehand") { print("TODO") },
                Button(textureName: "UI/SelectReplace") { print("TODO") }
            ], width: ButtonSize.medium.sideLength),
            ReLayout(undoView, width: ButtonSize.medium.sideLength),
            Button(textureName: "UI/Settings", size: .small) { print("TODO") },
            Button(textureName: "UI/Save", size: .small) { print("TODO") },
            Button(textureName: "UI/Quit", size: .small) { print("TODO") }
        ])
    }
}
