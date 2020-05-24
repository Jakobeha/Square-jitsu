//
//  EditorView.swift
//  Square-jitsu
//
//  Created by Jakob Hain on 5/19/20.
//  Copyright © 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class UndoView: UXCompoundView {
    private let undoManager: UndoManager

    init(undoManager: UndoManager) {
        self.undoManager = undoManager
    }

    override func newBody() -> UXView {
        undoManager.canRedo ? HStack([
            newUndoButton(),
            newRedoButton()
        ]) : newUndoButton()
    }

    private func newUndoButton() -> UXView {
        Button(textureName: "UI/Undo", isEnabled: undoManager.canUndo) { 
            self.undoManager.undo()
            self.regenerateBody()
        }
    }

    private func newRedoButton() -> UXView {
        Button(textureName: "UI/Redo") { 
            self.undoManager.redo()
            self.regenerateBody()
        }
    }
}
