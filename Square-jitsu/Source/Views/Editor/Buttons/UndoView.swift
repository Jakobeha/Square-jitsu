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
        super.init()
        // We use objc selectors so the observer is automatically removed when this is deallocated
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(regenerateBodyFromObjc),
            name: .NSUndoManagerDidCloseUndoGroup,
            object: self.undoManager
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(regenerateBodyFromObjc),
            name: .NSUndoManagerDidUndoChange,
            object: self.undoManager
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(regenerateBodyFromObjc),
            name: .NSUndoManagerDidRedoChange,
            object: self.undoManager
        )
    }

    @objc private func regenerateBodyFromObjc() {
        regenerateBody()
    }

    override func newBody() -> UXView {
        undoManager.canRedo ? HStack([
            newUndoButton(),
            newRedoButton()
        ]) : newUndoButton()
    }

    private func newUndoButton() -> UXView {
        Button(owner: self, textureName: "UI/Undo", isEnabled: undoManager.canUndo) { (self) in
            self.undoManager.undo()
            self.regenerateBody()
        }
    }

    private func newRedoButton() -> UXView {
        Button(owner: self, textureName: "UI/Redo") { (self) in
            self.undoManager.redo()
            self.regenerateBody()
        }
    }
}
