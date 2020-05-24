//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class EditorToolsTopView: UXCompoundView {
    private let editorTools: EditorTools

    private let tileMenuView: TileMenuView

    private var hasSelection: Bool {
        !editorTools.editAction.selectedPositions.isEmpty
    }

    init(editorTools: EditorTools) {
        self.editorTools = editorTools
        tileMenuView = TileMenuView(tileMenu: editorTools.tileMenu, settings: editorTools.world.settings)
        super.init()

        editorTools.didChangeEditActionMode.subscribe(observer: self) {
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        HStack([
            Button(textureName: "UI/RemoveTiles", isSelected: editorTools.editAction.mode == .remove) { 
                self.editorTools.select(actionMode: .remove)
            },
            Button(textureName: "UI/MoveTiles", isSelected: editorTools.editAction.mode == .move) {
                if self.hasSelection && self.editorTools.editAction.mode == .move {
                    // Does something different, because we are already in this mode, we clear the current selection
                    self.editorTools.editAction.selectedPositions.removeAll()
                } else {
                    self.editorTools.select(actionMode: .move)
                }
            },
            Button(textureName: "UI/InspectTiles", isSelected: editorTools.editAction.mode == .inspect) {
                if self.hasSelection && self.editorTools.editAction.mode == .inspect {
                    // Does something different, because we are already in this mode, we clear the current selection
                    self.editorTools.editAction.selectedPositions.removeAll()
                } else {
                    self.editorTools.select(actionMode: .inspect)
                }
            },
            Button(textureName: "UI/SelectTiles", isSelected: editorTools.editAction.mode == .select) {
                if self.hasSelection && self.editorTools.editAction.mode == .select {
                    // Does something different, because we are already in this mode, we clear the current selection
                    self.editorTools.editAction.selectedPositions.removeAll()
                } else {
                    self.editorTools.select(actionMode: .select)
                }
            },
            tileMenuView
        ])
    }
}
